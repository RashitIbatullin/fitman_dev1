import 'dart:convert';
import 'package:fitman_backend/config/database.dart';
import 'package:fitman_backend/modules/maintenance/models/equipment_maintenance_history.model.dart';
import 'package:postgres/postgres.dart';

abstract class MaintenanceRepository {
  Future<List<EquipmentMaintenanceHistory>> getAll();
  Future<EquipmentMaintenanceHistory> getById(String id);
  Future<List<EquipmentMaintenanceHistory>> getByEquipmentItemId(String equipmentItemId);
  Future<EquipmentMaintenanceHistory> create(EquipmentMaintenanceHistory history, String userId);
  Future<EquipmentMaintenanceHistory> update(String id, EquipmentMaintenanceHistory history, String userId);
  Future<void> archive(String id, String reason, String userId);
  Future<void> unarchive(String id);
  Future<void> addPhoto(String maintenanceId, String photoUrl, String comment, String timing, String takenBy);
}

class MaintenanceRepositoryImpl implements MaintenanceRepository {
  MaintenanceRepositoryImpl(this._db);

  final Database _db;

  @override
  Future<EquipmentMaintenanceHistory> create(EquipmentMaintenanceHistory history, String userId) async {
    final conn = await _db.connection;
    final result = await conn.execute(
      Sql.named('''
        INSERT INTO equipment_maintenance_history (
          equipment_item_id, equipment_name, type, status,
          created_at, started_at, completed_at, equipment_available_from,
          reported_problem, work_description, reported_by,
          assigned_to_user_id, assigned_to_staff_id, related_booking_id,
          caused_downtime, updated_at, photos,
          created_by, updated_by
        ) VALUES (
          @equipmentItemId, @equipmentName, @type, @status,
          @createdAt, @startedAt, @completedAt, @equipmentAvailableFrom,
          @reportedProblem, @workDescription, @reportedBy,
          @assignedToUserId, @assignedToStaffId, @relatedBookingId,
          @causedDowntime, NOW(), @photos,
          @createdBy, @updatedBy
        ) RETURNING id;
      '''),
      parameters: {
        'equipmentItemId': history.equipmentItemId,
        'equipmentName': history.equipmentName,
        'type': history.type.index,
        'status': history.status.index,
        'createdAt': history.createdAt ?? DateTime.now(),
        'startedAt': history.startedAt,
        'completedAt': history.completedAt,
        'equipmentAvailableFrom': history.equipmentAvailableFrom,
        'reportedProblem': history.reportedProblem,
        'workDescription': history.workDescription,
        'reportedBy': history.reportedBy,
        'assignedToUserId': history.assignedToUserId,
        'assignedToStaffId': history.assignedToStaffId,
        'relatedBookingId': history.relatedBookingId,
        'causedDowntime': history.causedDowntime,
        'photos': history.photos != null ? jsonEncode(history.photos!.map((p) => p.toJson()).toList()) : null,
        'createdBy': userId,
        'updatedBy': userId,
      },
    );

    final newId = result.first.first as int;
    return await getById(newId.toString());
  }

  @override
  Future<List<EquipmentMaintenanceHistory>> getAll() async {
    final conn = await _db.connection;
    final result = await conn.execute(
      Sql.named('SELECT * FROM equipment_maintenance_history WHERE archived_at IS NULL ORDER BY created_at DESC'),
    );

    return result.map((row) {
      final rowMap = row.toColumnMap();
      return EquipmentMaintenanceHistory.fromJson(rowMap);
    }).toList();
  }

  @override
  Future<EquipmentMaintenanceHistory> getById(String id) async {
    final conn = await _db.connection;
    final result = await conn.execute(
      Sql.named('SELECT * FROM equipment_maintenance_history WHERE id = @id'),
      parameters: {'id': id},
    );

    if (result.isEmpty) {
      throw Exception('EquipmentMaintenanceHistory with id $id not found');
    }

    return EquipmentMaintenanceHistory.fromJson(result.first.toColumnMap());
  }

  @override
  Future<List<EquipmentMaintenanceHistory>> getByEquipmentItemId(String equipmentItemId) async {
    final conn = await _db.connection;
    final result = await conn.execute(
      Sql.named('SELECT * FROM equipment_maintenance_history WHERE equipment_item_id = @equipmentItemId AND archived_at IS NULL ORDER BY created_at DESC'),
      parameters: {'equipmentItemId': equipmentItemId},
    );

    return result.map((row) {
      final rowMap = row.toColumnMap();
      print('Repository: Raw row from DB: $rowMap'); // Keep this debug line for now
      return EquipmentMaintenanceHistory.fromJson(rowMap);
    }).toList();
  }

  @override
  Future<EquipmentMaintenanceHistory> update(String id, EquipmentMaintenanceHistory history, String userId) async {
     final conn = await _db.connection;
    await conn.execute(
      Sql.named('''
        UPDATE equipment_maintenance_history SET
          equipment_name = @equipmentName,
          type = @type,
          status = @status,
          created_at = @createdAt,
          started_at = @startedAt,
          completed_at = @completedAt,
          equipment_available_from = @equipmentAvailableFrom,
          reported_problem = @reportedProblem,
          work_description = @workDescription,
          reported_by = @reportedBy,
          assigned_to_user_id = @assignedToUserId,
          assigned_to_staff_id = @assignedToStaffId,
          related_booking_id = @relatedBookingId,
          caused_downtime = @causedDowntime,
          updated_at = NOW(),
          archived_at = @archivedAt,
          archived_by = @archivedBy,
          archived_reason = @archivedReason,
          photos = @photos,
          updated_by = @updatedBy
        WHERE id = @id;
      '''),
      parameters: {
        'id': id,
        'equipmentName': history.equipmentName,
        'type': history.type.index,
        'status': history.status.index,
        'createdAt': history.createdAt,
        'startedAt': history.startedAt,
        'completedAt': history.completedAt,
        'equipmentAvailableFrom': history.equipmentAvailableFrom,
        'reportedProblem': history.reportedProblem,
        'workDescription': history.workDescription,
        'reportedBy': history.reportedBy,
        'assignedToUserId': history.assignedToUserId,
        'assignedToStaffId': history.assignedToStaffId,
        'relatedBookingId': history.relatedBookingId,
        'causedDowntime': history.causedDowntime,
        'archivedAt': history.archivedAt,
        'archivedBy': history.archivedBy,
        'archivedReason': history.archivedReason,
        'photos': history.photos != null ? jsonEncode(history.photos!.map((p) => p.toJson()).toList()) : null,
        'updatedBy': userId,
      },
    );
    return await getById(id);
  }

  @override
  Future<void> archive(String id, String reason, String userId) async {
    final conn = await _db.connection;
    await conn.execute(
      Sql.named(
          'UPDATE equipment_maintenance_history SET archived_at = NOW(), archived_by = @userId, archived_reason = @reason WHERE id = @id'),
      parameters: {
        'id': id,
        'reason': reason,
        'userId': userId,
      },
    );
  }

  @override
  Future<void> unarchive(String id) async {
    final conn = await _db.connection;
    await conn.execute(
      Sql.named(
          'UPDATE equipment_maintenance_history SET archived_at = NULL, archived_by = NULL, archived_reason = NULL WHERE id = @id'),
      parameters: {
        'id': id,
      },
    );
  }

  @override
  Future<void> addPhoto(String maintenanceId, String photoUrl, String comment, String timing, String takenBy) async {
    final conn = await _db.connection;
    await conn.execute(
      Sql.named('''
        INSERT INTO maintenance_photos (maintenance_id, url, comment, timing, taken_by)
        VALUES (@maintenanceId, @url, @comment, @timing, @takenBy)
      '''),
      parameters: {
        'maintenanceId': maintenanceId,
        'url': photoUrl,
        'comment': comment,
        'timing': timing,
        'takenBy': takenBy,
      },
    );
  }
}