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

  /// Prepares a row map from the database for consumption by a `fromJson` factory.
  /// It correctly handles `snake_case` to `camelCase` conversion expectation by:
  /// 1. Converting integer IDs to strings.
  /// 2. Converting integer enums to string names.
  /// 3. Converting DateTime objects to ISO 8601 strings.
  Map<String, dynamic> _prepareRowForFromJson(Map<String, dynamic> row) {
    final newRow = {...row};

    // Convert enums from int (from DB) to String name (for fromJson)
    if (newRow['type'] != null && newRow['type'] is int) {
      newRow['type'] = MaintenanceType.values[newRow['type']].name;
    }
    if (newRow['status'] != null && newRow['status'] is int) {
      newRow['status'] = MaintenanceStatus.values[newRow['status']].name;
    }

    // Convert all potential ID columns from int to String
    final idKeys = ['id', 'equipment_item_id', 'reported_by', 'assigned_to_user_id', 'assigned_to_staff_id', 'related_booking_id', 'archived_by', 'created_by', 'updated_by'];
    for (final key in idKeys) {
      if (newRow[key] != null && newRow[key] is! String) {
        newRow[key] = newRow[key].toString();
      }
    }
    
    // Convert all potential DateTime columns to ISO 8601 strings
    final dateKeys = ['created_at', 'started_at', 'completed_at', 'equipment_available_from', 'updated_at', 'archived_at'];
    for (final key in dateKeys) {
        if (newRow[key] != null && newRow[key] is DateTime) {
            newRow[key] = (newRow[key] as DateTime).toIso8601String();
        }
    }

    return newRow;
  }

  @override
  Future<EquipmentMaintenanceHistory> create(EquipmentMaintenanceHistory history, String userId) async {
    final conn = await _db.connection;
    final result = await conn.execute(
      Sql.named('''
        INSERT INTO equipment_maintenance_history (
          equipment_item_id, equipment_name, type, status, created_at, 
          started_at, completed_at, equipment_available_from, reported_problem, 
          work_description, reported_by, assigned_to_user_id, assigned_to_staff_id, 
          related_booking_id, caused_downtime, updated_at
        ) VALUES (
          @equipment_item_id, @equipment_name, @type, @status, @created_at,
          @started_at, @completed_at, @equipment_available_from, @reported_problem,
          @work_description, @reported_by, @assigned_to_user_id, @assigned_to_staff_id,
          @related_booking_id, @caused_downtime, NOW()
        ) RETURNING *;
      '''),
      parameters: {
        'equipment_item_id': int.tryParse(history.equipmentItemId),
        'equipment_name': history.equipmentName,
        'type': history.type.index,
        'status': history.status.index,
        'created_at': history.createdAt ?? DateTime.now(),
        'started_at': history.startedAt,
        'completed_at': history.completedAt,
        'equipment_available_from': history.equipmentAvailableFrom,
        'reported_problem': history.reportedProblem,
        'work_description': history.workDescription,
        'reported_by': int.tryParse(history.reportedBy),
        'assigned_to_user_id': history.assignedToUserId != null ? int.tryParse(history.assignedToUserId!) : null,
        'assigned_to_staff_id': history.assignedToStaffId != null ? int.tryParse(history.assignedToStaffId!) : null,
        'related_booking_id': history.relatedBookingId != null ? int.tryParse(history.relatedBookingId!) : null,
        'caused_downtime': history.causedDowntime,
      },
    );

    final newId = result.first[0] as int;
    return await getById(newId.toString());
  }

  @override
  Future<List<EquipmentMaintenanceHistory>> getAll() async {
    final conn = await _db.connection;
    const query = '''
      SELECT 
        emh.*,
        COALESCE(
          (SELECT json_agg(p.*)
           FROM maintenance_photos p
           WHERE p.maintenance_id = emh.id),
          '[]'::json
        ) as photos
      FROM equipment_maintenance_history emh
      WHERE emh.archived_at IS NULL
      ORDER BY emh.created_at DESC
    ''';

    final result = await conn.execute(Sql.named(query));

    return result.map((row) {
      final rowMap = row.toColumnMap();

      if (rowMap['photos'] != null && rowMap['photos'] is List) {
        final photosList = rowMap['photos'] as List;
        rowMap['photos'] = photosList.map((photo) {
          final pMap = photo as Map<String, dynamic>;
          if (pMap['timing'] != null && pMap['timing'] is int) {
            pMap['timing'] = PhotoTiming.values[pMap['timing']].name;
          }
          // Convert relevant photo IDs to string
          for (final key in ['id', 'maintenance_id', 'taken_by']) {
            if (pMap[key] != null) pMap[key] = pMap[key].toString();
          }
          return pMap;
        }).toList();
      }

      final preparedRow = _prepareRowForFromJson(rowMap);
      return EquipmentMaintenanceHistory.fromJson(preparedRow);
    }).toList();
  }

  @override
  Future<EquipmentMaintenanceHistory> getById(String id) async {
    final conn = await _db.connection;
    const query = '''
      SELECT 
        emh.*,
        COALESCE(
          (SELECT json_agg(p.*)
           FROM maintenance_photos p
           WHERE p.maintenance_id = emh.id),
          '[]'::json
        ) as photos
      FROM equipment_maintenance_history emh
      WHERE emh.id = @id
    ''';

    final result = await conn.execute(
      Sql.named(query),
      parameters: {'id': int.tryParse(id) ?? 0},
    );

    if (result.isEmpty) {
      throw Exception('EquipmentMaintenanceHistory with id $id not found');
    }

    final rowMap = result.first.toColumnMap();
    if (rowMap['photos'] != null && rowMap['photos'] is List) {
      final photosList = rowMap['photos'] as List;
      rowMap['photos'] = photosList.map((photo) {
        final pMap = photo as Map<String, dynamic>;
        if (pMap['timing'] != null && pMap['timing'] is int) {
          pMap['timing'] = PhotoTiming.values[pMap['timing']].name;
        }
        for (final key in ['id', 'maintenance_id', 'taken_by']) {
          if (pMap[key] != null) pMap[key] = pMap[key].toString();
        }
        return pMap;
      }).toList();
    }
    
    final preparedRow = _prepareRowForFromJson(rowMap);
    return EquipmentMaintenanceHistory.fromJson(preparedRow);
  }

  @override
  Future<List<EquipmentMaintenanceHistory>> getByEquipmentItemId(String equipmentItemId) async {
    final conn = await _db.connection;
    const query = '''
      SELECT 
        emh.*,
        COALESCE(
          (SELECT json_agg(p.*)
           FROM maintenance_photos p
           WHERE p.maintenance_id = emh.id),
          '[]'::json
        ) as photos
      FROM equipment_maintenance_history emh
      WHERE emh.equipment_item_id = @equipment_item_id AND emh.archived_at IS NULL
      ORDER BY emh.created_at DESC
    ''';

    final result = await conn.execute(
      Sql.named(query),
      parameters: {'equipment_item_id': int.tryParse(equipmentItemId) ?? 0},
    );

    return result.map((row) {
      final rowMap = row.toColumnMap();
      if (rowMap['photos'] != null && rowMap['photos'] is List) {
        final photosList = rowMap['photos'] as List;
        rowMap['photos'] = photosList.map((photo) {
          final pMap = photo as Map<String, dynamic>;
          if (pMap['timing'] != null && pMap['timing'] is int) {
            pMap['timing'] = PhotoTiming.values[pMap['timing']].name;
          }
          for (final key in ['id', 'maintenance_id', 'taken_by']) {
            if (pMap[key] != null) pMap[key] = pMap[key].toString();
          }
          return pMap;
        }).toList();
      }
      final preparedRow = _prepareRowForFromJson(rowMap);
      return EquipmentMaintenanceHistory.fromJson(preparedRow);
    }).toList();
  }

  @override
  Future<EquipmentMaintenanceHistory> update(String id, EquipmentMaintenanceHistory history, String userId) async {
     final conn = await _db.connection;
    await conn.execute(
      Sql.named('''
        UPDATE equipment_maintenance_history SET
          equipment_name = @equipment_name,
          type = @type,
          status = @status,
          started_at = @started_at,
          completed_at = @completed_at,
          equipment_available_from = @equipment_available_from,
          reported_problem = @reported_problem,
          work_description = @work_description,
          assigned_to_user_id = @assigned_to_user_id,
          assigned_to_staff_id = @assigned_to_staff_id,
          related_booking_id = @related_booking_id,
          caused_downtime = @caused_downtime,
          updated_at = NOW(),
          archived_at = @archived_at,
          archived_by = @archived_by,
          archived_reason = @archived_reason
        WHERE id = @id;
      '''),
      parameters: {
        'id': int.tryParse(id) ?? 0,
        'equipment_name': history.equipmentName,
        'type': history.type.index,
        'status': history.status.index,
        'started_at': history.startedAt,
        'completed_at': history.completedAt,
        'equipment_available_from': history.equipmentAvailableFrom,
        'reported_problem': history.reportedProblem,
        'work_description': history.workDescription,
        'assigned_to_user_id': history.assignedToUserId != null ? int.tryParse(history.assignedToUserId!) : null,
        'assigned_to_staff_id': history.assignedToStaffId != null ? int.tryParse(history.assignedToStaffId!) : null,
        'related_booking_id': history.relatedBookingId != null ? int.tryParse(history.relatedBookingId!) : null,
        'caused_downtime': history.causedDowntime,
        'archived_at': history.archivedAt,
        'archived_by': history.archivedBy != null ? int.tryParse(history.archivedBy!) : null,
        'archived_reason': history.archivedReason,
      },
    );
    return await getById(id);
  }

  @override
  Future<void> archive(String id, String reason, String userId) async {
    final conn = await _db.connection;
    await conn.execute(
      Sql.named(
          'UPDATE equipment_maintenance_history SET archived_at = NOW(), archived_by = @user_id, archived_reason = @reason WHERE id = @id'),
      parameters: {
        'id': int.tryParse(id) ?? 0,
        'reason': reason,
        'user_id': int.tryParse(userId) ?? 0,
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
        'id': int.tryParse(id) ?? 0,
      },
    );
  }

  @override
  Future<void> addPhoto(String maintenanceId, String photoUrl, String comment, String timing, String takenBy) async {
    final conn = await _db.connection;
    
    final params = {
      'maintenance_id': int.tryParse(maintenanceId) ?? 0,
      'url': photoUrl,
      'comment': comment,
      'timing': PhotoTiming.values.byName(timing).index,
      'taken_by': int.tryParse(takenBy) ?? 0,
    };

    print('--- ADDING PHOTO TO DB ---');
    print('Parameters: $params');

    final result = await conn.execute(
      Sql.named('''
        INSERT INTO maintenance_photos (maintenance_id, url, comment, timing, taken_by)
        VALUES (@maintenance_id, @url, @comment, @timing, @taken_by)
      '''),
      parameters: params,
    );

    print('Result: ${result.affectedRows} row(s) affected.');
    print('--- FINISHED ADDING PHOTO ---');
  }
}
