import 'package:fitman_backend/config/database.dart';
import 'package:fitman_backend/modules/rooms/models/building/building.model.dart';
import 'package:postgres/postgres.dart';

class BuildingRepository {
  const BuildingRepository(this._db);

  final Database _db;

  Future<List<Building>> selectAll({bool? isArchived}) async {
    final conn = await _db.connection;
    var query = '''
      SELECT 
        b.*, 
        (archiver.last_name || ' ' || archiver.first_name) AS archived_by_name
      FROM buildings b
      LEFT JOIN users archiver ON b.archived_by = archiver.id
    ''';
    if (isArchived != null) {
      query += isArchived
          ? ' WHERE b.archived_at IS NOT NULL'
          : ' WHERE b.archived_at IS NULL';
    }
    final result = await conn.execute(query);
    return result.map((row) => Building.fromMap(row.toColumnMap())).toList();
  }

  Future<Building?> selectById(String id) async {
    final conn = await _db.connection;
    final result = await conn.execute(
      Sql.named('''
        SELECT 
          b.*, 
          (archiver.last_name || ' ' || archiver.first_name) AS archived_by_name
        FROM buildings b
        LEFT JOIN users archiver ON b.archived_by = archiver.id
        WHERE b.id = @id
      '''),
      parameters: {'id': int.parse(id)},
    );
    return result.isEmpty ? null : Building.fromMap(result.first.toColumnMap());
  }

  Future<Building?> selectByName(String name) async {
    final conn = await _db.connection;
    final result = await conn.execute(
      Sql.named('''
        SELECT 
          b.*, 
          (archiver.last_name || ' ' || archiver.first_name) AS archived_by_name
        FROM buildings b
        LEFT JOIN users archiver ON b.archived_by = archiver.id
        WHERE b.name = @name
      '''),
      parameters: {'name': name},
    );
    return result.isEmpty ? null : Building.fromMap(result.first.toColumnMap());
  }

  Future<Building> insert(Building building) async {
    final conn = await _db.connection;
    final result = await conn.execute(
      Sql.named('INSERT INTO buildings (name, address, note) VALUES (@name, @address, @note) RETURNING *'),
      parameters: {
        'name': building.name,
        'address': building.address,
        'note': building.note,
      },
    );
    return Building.fromMap(result.first.toColumnMap());
  }

  Future<Building> update(String id, Building building, String userId) async {
    final conn = await _db.connection;
    final result = await conn.execute(
      Sql.named('UPDATE buildings SET name = @name, address = @address, note = @note, updated_at = NOW(), updated_by = @updated_by, archived_at = @archived_at, archived_by = @archived_by, archived_reason = @archived_reason WHERE id = @id RETURNING *'),
      parameters: {
        'id': int.parse(id),
        'name': building.name,
        'address': building.address,
        'note': building.note,
        'archived_at': building.archivedAt,
        'updated_by': building.updatedBy != null ? int.parse(building.updatedBy!) : int.parse(userId), // Use userId if not provided in building object
        'archived_by': building.archivedBy != null ? int.parse(building.archivedBy!) : int.parse(userId), // Use userId if not provided in building object
        'archived_reason': building.archivedReason,
      },
    );
    return Building.fromMap(result.first.toColumnMap());
  }

  Future<void> archive(String id, int userId) async {
    final conn = await _db.connection;
    await conn.execute(
      Sql.named('UPDATE buildings SET archived_at = NOW(), archived_by = @userId WHERE id = @id'),
      parameters: {'id': int.parse(id), 'userId': userId},
    );
  }
}
