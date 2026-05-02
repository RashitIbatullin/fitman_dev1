import 'package:fitman_backend/config/database.dart';
import 'package:fitman_common/modules/equipment/equipment/equipment_type.model.dart';
import 'package:postgres/postgres.dart';

abstract class EquipmentTypeRepository {
  Future<EquipmentType> getById(String id);
  Future<List<EquipmentType>> getAll({bool? includeArchived});
  Future<EquipmentType> create(EquipmentType equipmentType, String userId);
  Future<EquipmentType> update(String id, EquipmentType equipmentType, String userId);
  Future<void> delete(String id);
  Future<void> archive(String id, String reason, String userId);
  Future<void> unarchive(String id);
}

class EquipmentTypeRepositoryImpl implements EquipmentTypeRepository {
  EquipmentTypeRepositoryImpl(this._db);

  final Database _db;

  @override
  Future<void> archive(String id, String reason, String userId) async {
    final conn = await _db.connection;
    await conn.execute(
      Sql.named(
          'UPDATE equipment_types SET archived_at = NOW(), archived_by = @userId, archived_reason = @reason WHERE id = @id'),
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
          'UPDATE equipment_types SET archived_at = NULL, archived_by = NULL, archived_reason = NULL WHERE id = @id'),
      parameters: {
        'id': id,
      },
    );
  }

  @override
  Future<EquipmentType> create(EquipmentType equipmentType, String userId) async {
    final conn = await _db.connection;
    final result = await conn.execute(
      Sql.named('''
        INSERT INTO equipment_types (
          name, description, category, weight_range, dimensions, is_mobile, schematic_icon,
          created_by, updated_by
        ) VALUES (
          @name, @description, @category, @weightRange, @dimensions, @isMobile, @schematicIcon,
          @createdBy, @updatedBy
        ) RETURNING id;
      '''),
      parameters: {
        'name': equipmentType.name,
        'description': equipmentType.description,
        'category': equipmentType.category.index,
        'weightRange': equipmentType.weightRange,
        'dimensions': equipmentType.dimensions,
        'isMobile': equipmentType.isMobile,
        'schematicIcon': equipmentType.schematicIcon,
        'createdBy': userId,
        'updatedBy': userId,
      },
    );

    final newId = result.first.first as String;
    return await getById(newId);
  }

  @override
  Future<void> delete(String id) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<List<EquipmentType>> getAll({bool? includeArchived}) async {
    try {
      final conn = await _db.connection;
      String whereClause;
      if (includeArchived == null) {
        whereClause = ''; // Get all
      } else if (includeArchived) {
        whereClause = 'WHERE archived_at IS NOT NULL'; // Get only archived
      } else {
        whereClause = 'WHERE archived_at IS NULL'; // Get only non-archived
      }
      final result = await conn.execute(
          Sql.named('SELECT * FROM equipment_types $whereClause ORDER BY name ASC'));

      return result.map((row) {
        final map = row.toColumnMap();
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
        return EquipmentType.fromJson(map);
      }).toList();
    } catch (e) {
      print('Error fetching all equipment types: $e');
      rethrow;
    }
  }

  @override
  Future<EquipmentType> getById(String id) async {
    final conn = await _db.connection;
    final result = await conn.execute(
      Sql.named('SELECT * FROM equipment_types WHERE id = @id'),
      parameters: {'id': id},
    );

    if (result.isEmpty) {
      throw Exception('EquipmentType with id $id not found');
    }

    final map = result.first.toColumnMap();
    if (map['archived_at'] is DateTime) {
      map['archived_at'] = (map['archived_at'] as DateTime).toIso8601String();
    }
    return EquipmentType.fromJson(map);
  }

  @override
  Future<EquipmentType> update(String id, EquipmentType equipmentType, String userId) async {
    final conn = await _db.connection;
    await conn.execute(
      Sql.named('''
        UPDATE equipment_types SET
          name = @name,
          description = @description,
          category = @category,
          weight_range = @weightRange,
          dimensions = @dimensions,
          is_mobile = @isMobile,
          schematic_icon = @schematicIcon,
          updated_at = NOW(),
          updated_by = @updatedBy,
          archived_at = @archivedAt,
          archived_by = @archivedBy,
          archived_reason = @archivedReason
        WHERE id = @id;
      '''),
      parameters: {
        'id': id,
        'name': equipmentType.name,
        'description': equipmentType.description,
        'category': equipmentType.category.index,
        'weightRange': equipmentType.weightRange,
        'dimensions': equipmentType.dimensions,
        'isMobile': equipmentType.isMobile,
        'schematicIcon': equipmentType.schematicIcon,
        'updatedBy': userId,
        'archivedAt': equipmentType.archivedAt,
        'archivedBy': equipmentType.archivedBy,
        'archivedReason': equipmentType.archivedReason,
      },
    );
    return await getById(id);
  }
}
