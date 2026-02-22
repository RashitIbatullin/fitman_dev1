import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:fitman_backend/modules/maintenance/models/equipment_maintenance_history.model.dart';
import 'package:fitman_backend/modules/maintenance/services/maintenance_service.dart';

class MaintenanceController {
  MaintenanceController(this._maintenanceService);

  final MaintenanceService _maintenanceService;

  Router get router {
    final router = Router();

    router.get('/', (Request request) async {
      try {
        final history = await _maintenanceService.getAll();
        final jsonResponse = jsonEncode(history.map((h) => h.toJson()).toList());
        return Response.ok(
          jsonResponse,
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(body: '{"error": "$e"}');
      }
    });

    router.get('/item/<itemId>', (Request request, String itemId) async {
      try {
        final history = await _maintenanceService.getByEquipmentItemId(itemId);
        final jsonResponse = jsonEncode(history.map((h) => h.toJson()).toList());
        return Response.ok(
          jsonResponse,
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(body: '{"error": "$e"}');
      }
    });

    router.post('/', (Request request) async {
      try {
        final body = await request.readAsString();
        final history = EquipmentMaintenanceHistory.fromJson(jsonDecode(body));
        final userId = request.context['user_id'] as String;
        final newHistory = await _maintenanceService.create(history, userId);
        return Response.ok(
          jsonEncode(newHistory.toJson()),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(body: '{"error": "$e"}');
      }
    });

    router.put('/<id>', (Request request, String id) async {
      try {
        final body = await request.readAsString();
        final history = EquipmentMaintenanceHistory.fromJson(jsonDecode(body));
        final userId = request.context['user_id'] as String;
        final updatedHistory = await _maintenanceService.update(id, history, userId);
        return Response.ok(
          jsonEncode(updatedHistory.toJson()),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(body: '{"error": "$e"}');
      }
    });

    router.delete('/<id>', (Request request, String id) async {
      try {
        final body = await request.readAsString();
        final params = jsonDecode(body);
        final reason = params['reason'] as String?;
        if (reason == null) {
          return Response.badRequest(body: '{"error": "Archival reason is required"}');
        }
        final userId = request.context['user_id'] as String;
        await _maintenanceService.archive(id, reason, userId);
        return Response.ok('{"message": "Record archived successfully"}');
      } catch (e) {
        return Response.internalServerError(body: '{"error": "$e"}');
      }
    });

    return router;
  }

  Handler get handler => router.call;
}