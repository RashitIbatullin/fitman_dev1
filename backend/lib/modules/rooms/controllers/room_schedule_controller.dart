import 'dart:async';
import 'dart:convert';
import 'package:fitman_backend/modules/rooms/services/room_schedule_service.dart';
import 'package:fitman_common/modules/rooms/room_schedule.model.dart';
import 'package:fitman_common/fitman_common.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class RoomScheduleController {
  RoomScheduleController(this._roomScheduleService);

  final RoomScheduleService _roomScheduleService;

  Router get router {
    final router = Router()
      ..get('/<roomId>/schedules', _getRoomSchedules)
      ..put('/<roomId>/schedules', _updateRoomSchedules);
    return router;
  }

  Future<Response> _getRoomSchedules(Request request, String roomId) async {
    try {
      final schedules = await _roomScheduleService.getSchedulesByRoomId(roomId);
      final schedulesJson = schedules.map((s) => s.toJson()).toList();
      return Response.ok(jsonEncode(schedulesJson));
    } on Exception catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      return Response.internalServerError(body: '{"error": "Error fetching room schedules: $errorMessage"}');
    }
  }

  Future<Response> _updateRoomSchedules(Request request, String roomId) async {
    try {
      final user = request.context['user'] as User?;
      if (user == null) {
        return Response.forbidden('{"error": "Authorization required. User payload missing."}');
      }
      final userId = user.id;

      final body = await request.readAsString();
      final List<dynamic> jsonList = jsonDecode(body);
      final schedules = jsonList.map((json) => RoomSchedule.fromJson(json as Map<String, dynamic>)).toList();
      
      await _roomScheduleService.updateSchedules(roomId, schedules, updatedBy: userId);
      return Response(204); // No Content
    } on Exception catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      return Response.internalServerError(body: '{"error": "$errorMessage"}');
    }
  }
}
