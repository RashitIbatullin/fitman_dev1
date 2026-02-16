import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../../config/database.dart';
import '../models/group_schedule.model.dart';

class GroupScheduleController {
  final Database _db;

  GroupScheduleController(this._db);

  Router get router {
    final router = Router();

    // The <groupId> will be part of the parent router's mount point
    router.get('/', _getGroupSchedules);
    router.post('/', _createGroupSchedule);
    router.put('/<slotId>', _updateGroupSchedule);
    router.delete('/<slotId>', _deleteGroupSchedule);

    return router;
  }

  Future<Response> _getGroupSchedules(Request request) async {
    try {
      final groupId = int.parse(request.params['groupId']!); // Assuming groupId is in context
      final slots = await _db.groups.getGroupSchedules(groupId);
      return Response.ok(jsonEncode(slots.map((s) => s.toJson()).toList()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    }
  }

  Future<Response> _createGroupSchedule(Request request) async {
    try {
      final groupId = int.parse(request.params['groupId']!);
      final payload = jsonDecode(await request.readAsString());
      final newSlot = GroupSchedule.fromJson({...payload, 'groupId': groupId});
      final createdSlot = await _db.groups.createGroupSchedule(newSlot);
      return Response(201, headers: {'Content-Type': 'application/json'}, body: jsonEncode(createdSlot.toJson()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    }
  }

  Future<Response> _updateGroupSchedule(Request request, String slotId) async {
    try {
      final id = int.parse(slotId);
      final payload = jsonDecode(await request.readAsString());
      final updatedSlot = GroupSchedule.fromJson({...payload, 'id': id});
      final resultSlot = await _db.groups.updateGroupSchedule(updatedSlot);
      return Response.ok(jsonEncode(resultSlot.toJson()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    }
  }

  Future<Response> _deleteGroupSchedule(Request request, String slotId) async {
    try {
      final id = int.parse(slotId);
      await _db.groups.deleteGroupSchedule(id);
      return Response(204);
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    }
  }
}
