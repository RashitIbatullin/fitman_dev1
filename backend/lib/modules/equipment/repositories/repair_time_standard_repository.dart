import 'package:postgres/postgres.dart';

import '../../../config/database.dart';
import 'package:fitman_common/modules/equipment/repair_time_standard.model.dart';

abstract class RepairTimeStandardRepository {
  Future<List<RepairTimeStandard>> getAll({bool includeArchived = false});
  Future<RepairTimeStandard> getById(String id);
  Future<RepairTimeStandard> create(RepairTimeStandard standard, String userId);
  Future<RepairTimeStandard> update(String id, RepairTimeStandard standard, String userId);
  Future<void> archive(String id, String userId, String reason);
  Future<void> unarchive(String id, String userId);
}

class RepairTimeStandardRepositoryImpl implements RepairTimeStandardRepository {
  RepairTimeStandardRepositoryImpl(this._db);

  final Database _db;

  @override
  Future<RepairTimeStandard> create(RepairTimeStandard standard, String userId) async {
    final conn = await _db.connection;
    final result = await conn.execute(
      Sql.named('INSERT INTO repair_time_standards (name, equipment_type_id, description, standard_duration_hours, complexity, created_by, updated_by) VALUES (@name, @equipmentTypeId, @description, @standardDurationHours, @complexity, @userId, @userId) RETURNING id'),
      parameters: {
        'name': standard.name,
        'equipmentTypeId': standard.equipmentTypeId,
        'description': standard.description,
        'standardDurationHours': standard.standardDurationHours,
        'complexity': standard.complexity?.index,
        'userId': userId,
      },
    );
     final newId = result.first[0] as String;
    return getById(newId);
  }

  @override
  Future<List<RepairTimeStandard>> getAll({bool includeArchived = false}) async {
    final conn = await _db.connection;
    final whereClause = includeArchived
        ? 'WHERE archived_at IS NOT NULL'
        : 'WHERE archived_at IS NULL';
    final result = await conn.execute(Sql.named(
        'SELECT * FROM repair_time_standards $whereClause ORDER BY name'));
    return result.map((row) {
      final map = row.toColumnMap();

      // Handle numeric and date conversions before passing to fromJson
      if (map['standard_duration_hours'] is String) {
        map['standard_duration_hours'] =
            double.parse(map['standard_duration_hours'] as String);
      }
      if (map['complexity'] is int) {
        final int complexityIndex = map['complexity'];
        if (complexityIndex >= 0 &&
            complexityIndex < RepairComplexity.values.length) {
          map['complexity'] = RepairComplexity.values[complexityIndex].name;
        }
      }
      if (map['archived_at'] is DateTime) {
        map['archived_at'] =
            (map['archived_at'] as DateTime).toIso8601String();
      }
      if (map['updated_at'] is DateTime) {
        map['updated_at'] =
            (map['updated_at'] as DateTime).toIso8601String();
      }
      if (map['created_at'] is DateTime) {
        map['created_at'] =
            (map['created_at'] as DateTime).toIso8601String();
      }
      return RepairTimeStandard.fromJson(map);
    }).toList();
  }

  @override
  Future<RepairTimeStandard> getById(String id) async {
    final conn = await _db.connection;
    final result = await conn.execute(
      Sql.named('SELECT * FROM repair_time_standards WHERE id = @id AND archived_at IS NULL'), 
      parameters: {'id': id}
    );
    if (result.isEmpty) {
      throw Exception('RepairTimeStandard with id $id not found');
    }
    final map = result.first.toColumnMap();
    if (map['standard_duration_hours'] is String) {
      map['standard_duration_hours'] = double.parse(map['standard_duration_hours'] as String);
    }
    if (map['complexity'] is int) {
      final int complexityIndex = map['complexity'];
      if (complexityIndex >= 0 && complexityIndex < RepairComplexity.values.length) {
        map['complexity'] = RepairComplexity.values[complexityIndex].name;
      }
    }
    if (map['archived_at'] is DateTime) {
      map['archived_at'] = (map['archived_at'] as DateTime).toIso8601String();
    }
    if (map['updated_at'] is DateTime) {
      map['updated_at'] = (map['updated_at'] as DateTime).toIso8601String();
    }
    if (map['created_at'] is DateTime) {
      map['created_at'] = (map['created_at'] as DateTime).toIso8601String();
    }
    return RepairTimeStandard.fromJson(map);
  }

  @override
  Future<RepairTimeStandard> update(String id, RepairTimeStandard standard, String userId) async {
    final conn = await _db.connection;
    await conn.execute(
      Sql.named('UPDATE repair_time_standards SET name = @name, equipment_type_id = @equipmentTypeId, description = @description, standard_duration_hours = @standardDurationHours, complexity = @complexity, updated_by = @userId, updated_at = NOW() WHERE id = @id'),
      parameters: {
        'id': id,
        'name': standard.name,
        'equipmentTypeId': standard.equipmentTypeId,
        'description': standard.description,
        'standardDurationHours': standard.standardDurationHours,
        'complexity': standard.complexity?.index,
        'userId': userId,
      },
    );
     return getById(id);
  }

  @override
  Future<void> archive(String id, String userId, String reason) async {
    final conn = await _db.connection;
    await conn.execute(
      Sql.named('UPDATE repair_time_standards SET archived_at = NOW(), archived_by = @userId, archived_reason = @reason WHERE id = @id'),
      parameters: {'id': id, 'userId': userId, 'reason': reason},
    );
  }

   @override
  Future<void> unarchive(String id, String userId) async {
    final conn = await _db.connection;
    await conn.execute(
      Sql.named('UPDATE repair_time_standards SET archived_at = NULL, archived_by = NULL, archived_reason = NULL, updated_by = @userId, updated_at = NOW() WHERE id = @id'),
      parameters: {'id': id, 'userId': userId},
    );
  }
}
