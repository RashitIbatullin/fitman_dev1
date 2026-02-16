import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:fitman_backend/modules/equipment/models/equipment_maintenance_history.model.dart';
import 'package:fitman_backend/modules/equipment/services/equipment.service.dart';

class EquipmentMaintenanceHistoryController {
  EquipmentMaintenanceHistoryController(this._equipmentService);

  final EquipmentService _equipmentService;

  Router get router {
    final router = Router();

    // Get all history for a specific equipment item
    router.get('/item/<itemId>', (Request request, String itemId) async {
      try {
        final history = await _equipmentService.getMaintenanceHistory(itemId);
        final jsonResponse = jsonEncode(history.map((h) => h.toJson()).toList());
        return Response.ok(
          jsonResponse,
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(body: '{"error": "$e"}');
      }
    });
    
    // Create a new maintenance history record
    router.post('/', (Request request) async {
      try {
        final body = await request.readAsString();
        final history = EquipmentMaintenanceHistory.fromJson(jsonDecode(body));
        final userId = request.context['user_id'] as String;
        final newHistory = await _equipmentService.createMaintenanceHistory(history, userId);
        return Response.ok(
          jsonEncode(newHistory.toJson()),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(body: '{"error": "$e"}');
      }
    });

    // Update a maintenance history record
    router.put('/<id>', (Request request, String id) async {
      try {
        final body = await request.readAsString();
        final history = EquipmentMaintenanceHistory.fromJson(jsonDecode(body));
        final userId = request.context['user_id'] as String;
        final updatedHistory = await _equipmentService.updateMaintenanceHistory(id, history, userId);
        return Response.ok(
          jsonEncode(updatedHistory.toJson()),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(body: '{"error": "$e"}');
      }
    });

    // Archive a maintenance history record
    router.delete('/<id>', (Request request, String id) async {
      try {
        final body = await request.readAsString();
        final params = jsonDecode(body);
        final reason = params['reason'] as String?;
        if (reason == null) {
          return Response.badRequest(body: '{"error": "Archival reason is required"}');
        }
        final userId = request.context['user_id'] as String;
        await _equipmentService.archiveMaintenanceHistory(id, reason, userId);
        return Response.ok('{"message": "Record archived successfully"}');
      } catch (e) {
        return Response.internalServerError(body: '{"error": "$e"}');
      }
    });

    return router;
  }

  Handler get handler => router.call;
}