import 'package:fitman_backend/config/database.dart';
import 'package:fitman_backend/modules/equipment/models/equipment_maintenance_history.model.dart';
import 'package:postgres/postgres.dart';

abstract class MaintenanceRepository {
  Future<List<EquipmentMaintenanceHistory>> getAll();
  Future<EquipmentMaintenanceHistory> getById(String id);
  Future<List<EquipmentMaintenanceHistory>> getByEquipmentItemId(String equipmentItemId, {bool isArchived = false});
  Future<EquipmentMaintenanceHistory> create(EquipmentMaintenanceHistory history, String userId);
  Future<EquipmentMaintenanceHistory> update(String id, EquipmentMaintenanceHistory history, String userId);
  Future<void> archive(String id, String reason, String userId);
  Future<void> unarchive(String id);
  Future<void> addPhoto(String maintenanceId, String photoUrl, String comment, String timing, String takenBy);
  Future<Map<String, List<Map<String, dynamic>>>> getAvailableExecutors();
}

class MaintenanceRepositoryImpl implements MaintenanceRepository {
  MaintenanceRepositoryImpl(this._db);

  final Database _db;

  String get _selectQueryFragment => '''
    SELECT 
      emh.number,
      emh.*,
      COALESCE(u.first_name || ' ' || u.last_name, ss.first_name || ' ' || ss.last_name) as executor_name,
      u_rb.first_name || ' ' || u_rb.last_name as reported_by_name,
      u_ip.first_name || ' ' || u_ip.last_name as in_progress_by_name,
      u_c.first_name || ' ' || u_c.last_name as completed_by_name,
      u_can.first_name || ' ' || u_can.last_name as cancelled_by_name,
      COALESCE(
        (SELECT json_agg(p.*)
         FROM maintenance_photos p
         WHERE p.maintenance_id = emh.id),
        '[]'::json
      ) as photos
    FROM equipment_maintenance_history emh
    LEFT JOIN users u ON emh.executor_id = u.id AND emh.executor_type = 0
    LEFT JOIN support_staff ss ON emh.executor_id = ss.id AND emh.executor_type = 1
    LEFT JOIN users u_ip ON emh.in_progress_by = u_ip.id
    LEFT JOIN users u_c ON emh.completed_by = u_c.id
    LEFT JOIN users u_can ON emh.cancelled_by = u_can.id
    LEFT JOIN users u_rb ON emh.reported_by = u_rb.id
  ''';

  /// Prepares a row map from the database for consumption by a `fromJson` factory.
  Map<String, dynamic> _prepareRowForFromJson(Map<String, dynamic> row) {
    final newRow = {...row};

    // Convert enums from int (from DB) to String name (for fromJson)
    if (newRow['type'] != null && newRow['type'] is int) {
      newRow['type'] = MaintenanceType.values[newRow['type']].name;
    }
    if (newRow['status'] != null && newRow['status'] is int) {
      newRow['status'] = MaintenanceStatus.values[newRow['status']].name;
    }
    if (newRow['executor_type'] != null && newRow['executor_type'] is int) {
      newRow['executor_type'] = ExecutorType.values[newRow['executor_type']].name;
    }

    // Convert all potential ID columns from int to String
    final idKeys = ['id', 'number', 'equipment_item_id', 'reported_by', 'reported_by_name', 'executor_id', 'related_booking_id', 'archived_by', 'created_by', 'updated_by', 'in_progress_by', 'completed_by', 'cancelled_by'];
    for (final key in idKeys) {
      if (newRow[key] != null && newRow[key] is! String) {
        newRow[key] = newRow[key].toString();
      }
    }
    
    // Convert all potential DateTime columns to ISO 8601 strings
    final dateKeys = ['created_at', 'started_at', 'completed_at', 'equipment_available_from', 'updated_at', 'archived_at', 'cancelled_at'];
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
          work_description, notes, reported_by, executor_id, executor_type, 
          related_booking_id, caused_downtime, updated_at, created_by, updated_by
        ) VALUES (
          @equipment_item_id, @equipment_name, @type, @status, @created_at,
          @started_at, @completed_at, @equipment_available_from, @reported_problem,
          @work_description, @notes, @reported_by, @executor_id, @executor_type,
          @related_booking_id, @caused_downtime, NOW(), @user_id, @user_id
        ) RETURNING id;
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
        'notes': history.notes,
        'reported_by': int.tryParse(history.reportedBy),
        'executor_id': history.executorId != null ? int.tryParse(history.executorId!) : null,
        'executor_type': history.executorType?.index,
        'related_booking_id': history.relatedBookingId != null ? int.tryParse(history.relatedBookingId!) : null,
        'caused_downtime': history.causedDowntime,
        'user_id': int.tryParse(userId),
      },
    );

    final newId = result.first[0] as int;
    return await getById(newId.toString());
  }

  @override
  Future<List<EquipmentMaintenanceHistory>> getAll() async {
    final conn = await _db.connection;
    final query = '''
      $_selectQueryFragment
      WHERE emh.archived_at IS NULL
      ORDER BY emh.created_at DESC
    ''';

    final result = await conn.execute(Sql.named(query));
    return _mapResultsToHistoryList(result);
  }

  @override
  Future<EquipmentMaintenanceHistory> getById(String id) async {
    final conn = await _db.connection;
    final query = '''
      $_selectQueryFragment
      WHERE emh.id = @id
    ''';

    final result = await conn.execute(
      Sql.named(query),
      parameters: {'id': int.tryParse(id) ?? 0},
    );

    if (result.isEmpty) {
      throw Exception('EquipmentMaintenanceHistory with id $id not found');
    }
    
    return _mapResultsToHistoryList(result).first;
  }

  @override
  Future<List<EquipmentMaintenanceHistory>> getByEquipmentItemId(String equipmentItemId, {bool isArchived = false}) async {
    final conn = await _db.connection;
    var query = '''
      $_selectQueryFragment
      WHERE emh.equipment_item_id = @equipment_item_id
    ''';

    if (isArchived) {
      query += ' AND emh.archived_at IS NOT NULL';
    } else {
      query += ' AND emh.archived_at IS NULL';
    }

    query += ' ORDER BY emh.created_at DESC';

    final result = await conn.execute(
      Sql.named(query),
      parameters: {'equipment_item_id': int.tryParse(equipmentItemId) ?? 0},
    );

    return _mapResultsToHistoryList(result);
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
          notes = @notes,
          executor_id = @executor_id,
          executor_type = @executor_type,
          related_booking_id = @related_booking_id,
          caused_downtime = @caused_downtime,
          updated_at = NOW(),
          updated_by = @user_id,
          archived_at = @archived_at,
          archived_by = @archived_by,
          archived_reason = @archived_reason,
          -- Новые поля
          repair_time_standard_id = @repair_time_standard_id,
          diagnosis_notes = @diagnosis_notes,
          actual_duration_hours = @actual_duration_hours,
          in_progress_by = @in_progress_by,
          completed_by = @completed_by,
          cancelled_by = @cancelled_by,
          cancelled_at = @cancelled_at,
          cancellation_reason = @cancellation_reason
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
        'notes': history.notes,
        'executor_id': history.executorId != null ? int.tryParse(history.executorId!) : null,
        'executor_type': history.executorType?.index,
        'related_booking_id': history.relatedBookingId != null ? int.tryParse(history.relatedBookingId!) : null,
        'caused_downtime': history.causedDowntime,
        'user_id': int.tryParse(userId),
        'archived_at': history.archivedAt,
        'archived_by': history.archivedBy != null ? int.tryParse(history.archivedBy!) : null,
        'archived_reason': history.archivedReason,
        // Новые параметры
        'repair_time_standard_id': history.repairTimeStandardId != null ? int.tryParse(history.repairTimeStandardId!) : null,
        'diagnosis_notes': history.diagnosisNotes,
        'actual_duration_hours': history.actualDurationHours,
        'in_progress_by': history.inProgressBy != null ? int.tryParse(history.inProgressBy!) : null,
        'completed_by': history.completedBy != null ? int.tryParse(history.completedBy!) : null,
        'cancelled_by': history.cancelledBy != null ? int.tryParse(history.cancelledBy!) : null,
        'cancelled_at': history.cancelledAt,
        'cancellation_reason': history.cancellationReason,
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
  Future<Map<String, List<Map<String, dynamic>>>> getAvailableExecutors() async {
    final conn = await _db.connection;

    final internalUsersQuery = '''
      SELECT DISTINCT
        u.id, 
        u.first_name, 
        u.last_name 
      FROM users u 
      JOIN employee_profiles ep ON u.id = ep.user_id
      LEFT JOIN competencies c ON u.id = c.competent_id AND c.executor_type = 0
      WHERE u.archived_at IS NULL 
        AND ep.can_maintain_equipment = true
        AND c.competent_id IS NOT NULL
      ORDER BY u.last_name, u.first_name;
    ''';
    
    final externalStaffQuery = '''
      SELECT 
        ss.id, 
        ss.first_name, 
        ss.last_name 
      FROM support_staff ss 
      WHERE ss.can_maintain_equipment = true AND ss.archived_at IS NULL
      ORDER BY ss.last_name, ss.first_name;
    ''';

    final internalResult = await conn.execute(Sql.named(internalUsersQuery));
    final externalResult = await conn.execute(Sql.named(externalStaffQuery));

    final internalExecutors = internalResult.map((row) {
      final colMap = row.toColumnMap();
      return {
        'id': colMap['id'].toString(),
        'first_name': colMap['first_name'],
        'last_name': colMap['last_name'],
      };
    }).toList();

    final externalExecutors = externalResult.map((row) {
      final colMap = row.toColumnMap();
      return {
        'id': colMap['id'].toString(),
        'first_name': colMap['first_name'],
        'last_name': colMap['last_name'],
      };
    }).toList();

    return {
      'users': internalExecutors,
      'staff': externalExecutors,
    };
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

    await conn.execute(
      Sql.named('''
        INSERT INTO maintenance_photos (maintenance_id, url, comment, timing, taken_by)
        VALUES (@maintenance_id, @url, @comment, @timing, @taken_by)
      '''),
      parameters: params,
    );
  }

  List<EquipmentMaintenanceHistory> _mapResultsToHistoryList(Result result) {
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
}
