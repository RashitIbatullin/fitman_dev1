import 'dart:convert';
import 'package:fitman_backend/config/database.dart';
import 'package:fitman_backend/modules/equipment/models/equipment/equipment_item.model.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class EquipmentItemController {
  EquipmentItemController(this._db) {
    _router
      ..get('/', _getAllEquipmentItems)
      ..post('/', _createEquipmentItem)
      ..get('/<id>', _getById) // Adding a GET by ID route for consistency
      ..put('/<id>', _updateEquipmentItem)
      ..put('/<id>/archive', _archive)
      ..put('/<id>/unarchive', _unarchive);
  }

  final Database _db;
  final _router = Router();

  Handler get handler => _router.call;

  Future<Response> _getById(Request request, String id) async {
    try {
      final equipmentItem = await _db.equipmentItems.getById(id);
      return Response.ok(jsonEncode(equipmentItem.toJson()));
    } catch (e) {
      return Response.internalServerError(
          body: '{"error": "Error fetching equipment item: $e"}');
    }
  }

  Future<Response> _getAllEquipmentItems(Request request) async {
    try {
      final roomId = request.url.queryParameters['roomId'];
      final includeArchived =
          request.url.queryParameters['includeArchived'] == 'true';

      late final List<EquipmentItem> equipmentItems;

      if (roomId != null && roomId.isNotEmpty) {
        equipmentItems = await _db.equipmentItems
            .getByRoomId(roomId, includeArchived: includeArchived);
      } else {
        equipmentItems =
            await _db.equipmentItems.getAll(includeArchived: includeArchived);
      }

      // --- START LOGGING ---
      print('--- Equipment Item Status Logging (Backend) ---');
      for (var item in equipmentItems) {
        print('Item ID: ${item.id}, Inventory: ${item.inventoryNumber}, Status: ${item.status}, Status Index: ${item.status.index}');
      }
      print('--- END LOGGING ---');
      final equipmentItemsJson =
          equipmentItems.map((item) => item.toJson()).toList();
      return Response.ok(jsonEncode(equipmentItemsJson));
    } catch (e) {
      return Response.internalServerError(
          body: '{"error": "Error fetching equipment items: $e"}');
    }
  }

  Future<Response> _createEquipmentItem(Request request) async {
    try {
      final body = await request.readAsString();
      final Map<String, dynamic> jsonBody = jsonDecode(body) as Map<String, dynamic>;
      
      // Get userId from request context
      final userPayload = request.context['user'] as Map<String, dynamic>?;
      if (userPayload == null) {
        return Response.unauthorized('{"error": "Authentication required"}');
      }
      final userId = userPayload['userId']?.toString();
      if (userId == null) {
        return Response.internalServerError(body: '{"error": "User ID not found in token payload"}');
      }

      final equipmentItem = EquipmentItem.fromJson(jsonBody);
      final createdEquipmentItem = await _db.equipmentItems.create(equipmentItem, userId);

      return Response.ok(jsonEncode(createdEquipmentItem.toJson()), headers: {'Content-Type': 'application/json'});
    } catch (e) {
      return Response.internalServerError(body: '{"error": "Error creating equipment item: $e"}');
    }
  }

  Future<Response> _updateEquipmentItem(Request request, String id) async {
    try {
      final body = await request.readAsString();
      final Map<String, dynamic> jsonBody = jsonDecode(body) as Map<String, dynamic>;

      // Get userId from request context
      final userPayload = request.context['user'] as Map<String, dynamic>?;
      if (userPayload == null) {
        return Response.unauthorized('{"error": "Authentication required"}');
      }
      final userId = userPayload['userId']?.toString();
      if (userId == null) {
        return Response.internalServerError(body: '{"error": "User ID not found in token payload"}');
      }
      
      final equipmentItem = EquipmentItem.fromJson(jsonBody);
      final updatedEquipmentItem = await _db.equipmentItems.update(id, equipmentItem, userId);

      return Response.ok(jsonEncode(updatedEquipmentItem.toJson()), headers: {'Content-Type': 'application/json'});
    } catch (e) {
      return Response.internalServerError(body: '{"error": "Error updating equipment item: $e"}');
    }
  }

  Future<Response> _archive(Request request, String id) async {
    try {
      final body = await request.readAsString();
      final params = jsonDecode(body) as Map<String, dynamic>;
      final reason = params['reason'] as String?;
      final userPayload = request.context['user'] as Map<String, dynamic>?;
      if (userPayload == null) {
        return Response.unauthorized('{"error": "Authentication required"}');
      }
      final userId = userPayload['userId']?.toString();
      if (userId == null) {
        return Response.internalServerError(body: '{"error": "User ID not found in token payload"}');
      }

      if (reason == null || reason.length < 5) {
        return Response.badRequest(
          body: '{"error": "Archival reason must be at least 5 characters long."}',
        );
      }

      await _db.equipmentItems.archive(id, reason, userId);

      return Response.ok('{"status": "success"}');
    } catch (e) {
      return Response.internalServerError(
          body: '{"error": "Error archiving equipment item: $e"}');
    }
  }

  Future<Response> _unarchive(Request request, String id) async {
    try {
      await _db.equipmentItems.unarchive(id);
      return Response.ok('{"status": "success"}');
    } catch (e) {
      return Response.internalServerError(
          body: '{"error": "Error unarchiving equipment item: $e"}');
    }
  }
}
