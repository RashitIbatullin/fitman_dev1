import 'dart:convert';
import 'package:fitman_common/fitman_common.dart';
import 'package:shelf/shelf.dart';
import '../../../config/database.dart'; // Adjusted relative path
import 'package:fitman_backend/errors/app_exception.dart';

class InstructorController {
  static Future<Response> getAssignedClients(Request request) async {
    try {
      final user = request.context['user'] as User?;
      if (user == null) {
        return Response.unauthorized('{"error": "Not authenticated"}');
      }

      final instructorId = user.id;

      final db = Database();
      final clients = await db.users.getClientsForInstructor(instructorId);

      final clientsJson = clients.map((client) => client.toJson()).toList();
      
      return Response.ok(
        jsonEncode(clientsJson),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (error, stackTrace) {
      throw InternalException(cause: error, stackTrace: stackTrace);
    }
  }

  static Future<Response> getAssignedTrainers(Request request) async {
    try {
      final user = request.context['user'] as User?;
      if (user == null) {
        return Response.unauthorized('{"error": "Not authenticated"}');
      }

      final instructorId = user.id;

      final db = Database();
      final trainers = await db.users.getTrainersForInstructor(instructorId);

      final trainersJson = trainers.map((trainer) => trainer.toJson()).toList();
      
      return Response.ok(
        jsonEncode(trainersJson),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (error, stackTrace) {
      throw InternalException(cause: error, stackTrace: stackTrace);
    }
  }

  static Future<Response> getAssignedManager(Request request) async {
    try {
      final user = request.context['user'] as User?;
      if (user == null) {
        return Response.unauthorized('{"error": "Not authenticated"}');
      }

      final instructorId = user.id;

      final db = Database();
      final manager = await db.users.getManagerForInstructor(instructorId);

      if (manager == null) {
        return Response.notFound('{"error": "Manager not found"}');
      }

      return Response.ok(
        jsonEncode(manager.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (error, stackTrace) {
      throw InternalException(cause: error, stackTrace: stackTrace);
    }
  }

  // === FOR ADMINS (getting data for a specific instructor) ===

  static Future<Response> getAssignedClientsForInstructor(Request request, String instructorId) async {
    try {
      final db = Database();
      final clients = await db.users.getClientsForInstructor(instructorId);
      final clientsJson = clients.map((client) => client.toJson()).toList();
      
      return Response.ok(
        jsonEncode(clientsJson),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (error, stackTrace) {
      throw InternalException(cause: error, stackTrace: stackTrace);
    }
  }

  static Future<Response> getAssignedTrainersForInstructor(Request request, String instructorId) async {
    try {
      final db = Database();
      final trainers = await db.users.getTrainersForInstructor(instructorId);
      final trainersJson = trainers.map((trainer) => trainer.toJson()).toList();
      
      return Response.ok(
        jsonEncode(trainersJson),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (error, stackTrace) {
      throw InternalException(cause: error, stackTrace: stackTrace);
    }
  }

  static Future<Response> getAssignedManagerForInstructor(Request request, String instructorId) async {
    try {
      final db = Database();
      final manager = await db.users.getManagerForInstructor(instructorId);

      if (manager == null) {
        return Response.notFound('{"error": "Manager not found for instructor $instructorId"}');
      }

      return Response.ok(
        jsonEncode(manager.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (error, stackTrace) {
      throw InternalException(cause: error, stackTrace: stackTrace);
    }
  }
}
