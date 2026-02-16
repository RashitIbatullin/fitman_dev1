import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../../config/database.dart';
import '../models/training_group_type.model.dart';

class TrainingGroupTypesController {
  final Database _db;

  TrainingGroupTypesController(this._db);

  Router get router {
    final router = Router();
    router.get('/', _getAllTypes);
    return router;
  }

  Future<Response> _getAllTypes(Request request) async {
    try {
      final List<TrainingGroupType> types = await _db.groups.getAllTrainingGroupTypes();
      return Response.ok(jsonEncode(types.map((t) => t.toJson()).toList()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    }
  }
}
