import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../config/database.dart';

class CatalogsController {
  static Future<Response> _getCatalog(String tableName) async {
    try {
      final results = await Database().getCatalog(tableName);
      return Response.ok(jsonEncode(results));
    } catch (e) {
      return Response.internalServerError(body: '{"error": "Failed to fetch catalog $tableName: $e"}');
    }
  }

  static Future<Response> getGoalsTraining(Request request) async {
    return _getCatalog('goals_training');
  }

  static Future<Response> getLevelsTraining(Request request) async {
    return _getCatalog('levels_training');
  }
}
