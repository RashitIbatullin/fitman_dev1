import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../config/database.dart';
import '../errors/app_exception.dart';

class CatalogsController {
  static Future<Response> _getCatalog(String tableName) async {
    try {
      final results = await Database().catalogs.getCatalog(tableName);
      return Response.ok(jsonEncode(results));
    } catch (error, stackTrace) {
      throw InternalException(cause: error, stackTrace: stackTrace);
    }
  }

  static Future<Response> getGoalsTraining(Request request) async {
    return _getCatalog('goals_training');
  }

  static Future<Response> getLevelsTraining(Request request) async {
    return _getCatalog('levels_training');
  }
}
