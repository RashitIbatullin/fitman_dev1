import 'package:postgres/postgres.dart';

import '../../../config/database.dart';

abstract class CatalogRepository {
  Future<List<Map<String, dynamic>>> getCatalog(String tableName);
}

class CatalogRepositoryImpl implements CatalogRepository {
  CatalogRepositoryImpl(this._db);

  final Database _db;

  Future<Connection> get _connection => _db.connection;

  @override
  Future<List<Map<String, dynamic>>> getCatalog(String tableName) async {
    try {
      final conn = await _connection;
      // Basic validation to prevent SQL injection, although table names from client are risky.
      // A better approach would be a whitelist of allowed table names.
      final allowedTables = ['training_plan_templates', 'goals_training', 'levels_training'];
      if (!allowedTables.contains(tableName)) {
        throw ArgumentError.value(tableName, 'tableName', 'Unsupported catalog');
      }

      final results = await conn.execute('SELECT id, name FROM $tableName WHERE archived_at IS NULL ORDER BY id');
      return results.map((row) => row.toColumnMap()).toList();
    } catch (e) {
      print('❌ getCatalog ($tableName) error: $e');
      rethrow;
    }
  }
}
