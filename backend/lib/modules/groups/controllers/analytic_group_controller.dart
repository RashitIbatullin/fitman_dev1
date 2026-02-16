import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../../config/database.dart';
import '../models/analytic_group.model.dart';

class AnalyticGroupsController {
  final Database _db;

  AnalyticGroupsController(this._db);

  Router get router {
    final router = Router();

    router.get('/', _getAllAnalyticGroups);
    router.get('/<id>', _getAnalyticGroupById);
    router.post('/', _createAnalyticGroup);
    router.put('/<id>', _updateAnalyticGroup);
    router.delete('/<id>', _deleteAnalyticGroup);

    return router;
  }

  Future<Response> _getAllAnalyticGroups(Request request) async {
    try {
      final queryParams = request.url.queryParameters;
      final bool? isArchived = queryParams['isArchived'] != null ? bool.parse(queryParams['isArchived']!) : null;

      final groups = await _db.groups.getAllAnalyticGroups(
        isArchived: isArchived,
      );
      return Response.ok(jsonEncode(groups.map((g) => g.toJson()).toList()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    }
  }

  Future<Response> _getAnalyticGroupById(Request request, String id) async {
    try {
      final groupId = int.parse(id);
      final group = await _db.groups.getAnalyticGroupById(groupId);
      if (group == null) {
        return Response.notFound(jsonEncode({'error': 'AnalyticGroup not found'}));
      }
      return Response.ok(jsonEncode(group.toJson()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    }
  }

  Future<Response> _createAnalyticGroup(Request request) async {
    try {
      final payload = jsonDecode(await request.readAsString());
      // TODO: Get creatorId from authenticated user context
      const creatorId = 1; // Placeholder for now

      final newGroup = AnalyticGroup.fromJson(payload);
      final createdGroup = await _db.groups.createAnalyticGroup(newGroup, creatorId);
      return Response(201, headers: {'Content-Type': 'application/json', 'Location': '/analytic_groups/${createdGroup.id}'}, body: jsonEncode(createdGroup.toJson()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    }
  }

  Future<Response> _updateAnalyticGroup(Request request, String id) async {
    try {
      final groupId = int.parse(id);
      final payload = jsonDecode(await request.readAsString());
      // TODO: Get updaterId from authenticated user context
      const updaterId = 1; // Placeholder for now

      final updatedGroup = AnalyticGroup.fromJson({
        ...payload,
        'id': groupId, // Ensure ID is from path and is an int
      });
      final resultGroup = await _db.groups.updateAnalyticGroup(updatedGroup, updaterId);
      return Response.ok(jsonEncode(resultGroup.toJson()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    }
  }

  Future<Response> _deleteAnalyticGroup(Request request, String id) async {
    try {
      final groupId = int.parse(id);
      // TODO: Get archiverId from authenticated user context
      const archiverId = 1; // Placeholder for now
      await _db.groups.deleteAnalyticGroup(groupId, archiverId);
      return Response(204);
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    }
  }
}