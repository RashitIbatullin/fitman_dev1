import 'dart:convert';
import 'package:fitman_backend/config/database.dart';
import 'package:fitman_backend/modules/equipment/models/equipment_maintenance_history.model.dart';
import 'package:postgres/postgres.dart';

abstract class EquipmentMaintenanceHistoryRepository {
  Future<EquipmentMaintenanceHistory> getById(String id);
  Future<List<EquipmentMaintenanceHistory>> getByEquipmentItemId(String equipmentItemId);
  Future<EquipmentMaintenanceHistory> create(EquipmentMaintenanceHistory history, String userId);
  Future<EquipmentMaintenanceHistory> update(String id, EquipmentMaintenanceHistory history, String userId);
  Future<void> archive(String id, String reason, String userId);
  Future<void> unarchive(String id);
}

class EquipmentMaintenanceHistoryRepositoryImpl implements EquipmentMaintenanceHistoryRepository {
  EquipmentMaintenanceHistoryRepositoryImpl(this._db);

  final Database _db;

  @override
  Future<EquipmentMaintenanceHistory> create(EquipmentMaintenanceHistory history, String userId) async {
    final conn = await _db.connection;
    final result = await conn.execute(
      Sql.named('''
        INSERT INTO equipment_maintenance_history (
          equipment_item_id, date_sent, date_returned, description_of_work, cost,
          performed_by, photos,
          company_id, created_at, updated_at, created_by, updated_by
        ) VALUES (
          @equipmentItemId, @dateSent, @dateReturned, @descriptionOfWork, @cost,
          @performedBy, @photos,
          -1, NOW(), NOW(), @createdBy, @updatedBy
        ) RETURNING id;
      '''),
      parameters: {
        'equipmentItemId': history.equipmentItemId,
        'dateSent': history.dateSent,
        'dateReturned': history.dateReturned,
        'descriptionOfWork': history.descriptionOfWork,
        'cost': history.cost,
        'performedBy': history.performedBy,
        'photos': history.photos != null ? jsonEncode(history.photos!.map((p) => p.toJson()).toList()) : null,
        'createdBy': userId,
        'updatedBy': userId,
      },
    );

    final newId = result.first.first as int;
    return await getById(newId.toString());
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

    return EquipmentMaintenanceHistory.fromMap(result.first.toColumnMap());
  }

  @override
  Future<List<EquipmentMaintenanceHistory>> getByEquipmentItemId(String equipmentItemId) async {
    final conn = await _db.connection;
    final result = await conn.execute(
      Sql.named('SELECT * FROM equipment_maintenance_history WHERE equipment_item_id = @equipmentItemId AND archived_at IS NULL ORDER BY date_sent DESC'),
      parameters: {'equipmentItemId': equipmentItemId},
    );

    return result.map((row) {
      final rowMap = row.toColumnMap();
      print('Repository: Raw row from DB: $rowMap'); // Add this line
      return EquipmentMaintenanceHistory.fromMap(rowMap);
    }).toList();
  }

  @override
  Future<EquipmentMaintenanceHistory> update(String id, EquipmentMaintenanceHistory history, String userId) async {
     final conn = await _db.connection;
    await conn.execute(
      Sql.named('''
        UPDATE equipment_maintenance_history SET
          date_sent = @dateSent,
          date_returned = @dateReturned,
          description_of_work = @descriptionOfWork,
          cost = @cost,
          performed_by = @performedBy,
          photos = @photos,
          updated_at = NOW(),
          updated_by = @updatedBy
        WHERE id = @id;
      '''),
      parameters: {
        'id': id,
        'dateSent': history.dateSent,
        'dateReturned': history.dateReturned,
        'descriptionOfWork': history.descriptionOfWork,
        'cost': history.cost,
        'performedBy': history.performedBy,
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
}