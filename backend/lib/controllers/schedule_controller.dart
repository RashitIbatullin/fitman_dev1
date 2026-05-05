import 'dart:convert';
import 'package:fitman_common/fitman_common.dart';
import 'package:shelf/shelf.dart';
import '../config/database.dart';

class ScheduleController {
  static Future<Response> getSchedule(Request request) async {
    try {
      final user = request.context['user'] as User?;
      if (user == null) {
        return Response.unauthorized('{"error": "Not authenticated"}');
      }

      final userId = user.id;
      final userRoles = user.roles.map((r) => r.name).toList();
      final userRole = userRoles.isNotEmpty ? userRoles.first : null;

      if (userRole == null) {
        return Response.badRequest(body: '{"error": "Invalid token payload"}');
      }

      final db = Database();
      final schedule = await db.schedules.getScheduleForUser(userId, userRole);

      // TODO: We need a way to serialize the schedule items to JSON.
      // For now, let's assume the schedule is a list of maps.
      return Response.ok(jsonEncode({'schedule': schedule}));

    } catch (e) {
      print('Get schedule error: $e');
      return Response(500, body: jsonEncode({'error': 'Internal server error'}));
    }
  }

  static Future<Response> createSchedule(Request request) async {
    try {
      final user = request.context['user'] as User?;
      if (user == null) {
        return Response(401, body: jsonEncode({'error': 'Not authenticated'}));
      }

      // Проверяем права (только тренер и админ могут создавать расписание)
      if (!user.roles.any((r) => r.name == 'trainer' || r.name == 'admin')) {
        return Response(403, body: jsonEncode({'error': 'Insufficient permissions'}));
      }

      // В MVP1 просто возвращаем успех
      return Response(201, body: jsonEncode({
        'message': 'Schedule created successfully',
        'schedule_id': DateTime.now().millisecondsSinceEpoch
      }));
    } catch (e) {
      print('Create schedule error: $e');
      return Response(500, body: jsonEncode({'error': 'Internal server error'}));
    }
  }
}