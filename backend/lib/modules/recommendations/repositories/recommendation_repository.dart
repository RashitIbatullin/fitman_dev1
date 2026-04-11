import 'package:postgres/postgres.dart';

import '../../../config/database.dart';

abstract class RecommendationRepository {
  Future<List<Map<String, dynamic>>> getSomatotypeRules();
  Future<List<Map<String, dynamic>>> getBodyShapeRecommendations();
  Future<List<Map<String, dynamic>>> getWhtrRefinements();
}

class RecommendationRepositoryImpl implements RecommendationRepository {
  RecommendationRepositoryImpl(this._db);

  final Database _db;

  Future<Connection> get _connection => _db.connection;

  @override
  Future<List<Map<String, dynamic>>> getSomatotypeRules() async {
    try {
      final conn = await _connection;
      final results = await conn.execute(
        Sql.named('SELECT * FROM types_body_build WHERE archived_at IS NULL'),
      );
      return results.map((row) => row.toColumnMap()).toList();
    } catch (e) {
      print('❌ getSomatotypeRules error: $e');
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getBodyShapeRecommendations() async {
    try {
      final conn = await _connection;
      final results = await conn.execute(
        Sql.named('SELECT * FROM body_shape_recommendations WHERE archived_at IS NULL'),
      );
      return results.map((row) => row.toColumnMap()).toList();
    } catch (e) {
      print('❌ getBodyShapeRecommendations error: $e');
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getWhtrRefinements() async {
    try {
      final conn = await _connection;
      final results = await conn.execute(
        Sql.named('SELECT * FROM whtr_refinements WHERE archived_at IS NULL'),
      );
      return results.map((row) => row.toColumnMap()).toList();
    } catch (e) {
      print('❌ getWhtrRefinements error: $e');
      rethrow;
    }
  }
}
