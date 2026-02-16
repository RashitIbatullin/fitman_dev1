import 'dart:convert';
import 'package:fitman_backend/config/database.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:fitman_backend/modules/equipment/models/equipment/equipment_type.model.dart';
import 'package:fitman_backend/modules/equipment/services/equipment.service.dart';

class EquipmentTypeController {
  EquipmentTypeController(this._db, this._equipmentService) {
    _router
      ..get('/', _getAllEquipmentTypes)
      ..post('/', _createEquipmentType)
      ..get('/<id>', _getById)
      ..put('/<id>', _updateEquipmentType)
      ..put('/<id>/archive', _archive)
      ..put('/<id>/unarchive', _unarchive);
  }

  final Database _db;
  final EquipmentService _equipmentService;
  final _router = Router();

  Handler get handler => _router.call;

  Future<Response> _getById(Request request, String id) async {
    try {
      final equipmentType = await _db.equipmentTypes.getById(id);
      return Response.ok(jsonEncode(equipmentType.toJson()));
    } catch (e) {
      return Response.internalServerError(
          body: '{"error": "Error fetching equipment type: $e"}');
    }
  }

  Future<Response> _getAllEquipmentTypes(Request request) async {
    try {
      final includeArchived =
          request.url.queryParameters['includeArchived'] == 'true';
      final equipmentTypes =
          await _db.equipmentTypes.getAll(includeArchived: includeArchived);
      final equipmentTypesJson =
          equipmentTypes.map((type) => type.toJson()).toList();
      return Response.ok(jsonEncode(equipmentTypesJson));
    } catch (e) {
      return Response.internalServerError(
          body: '{"error": "Error fetching equipment types: $e"}');
    }
  }

  Future<Response> _createEquipmentType(Request request) async {
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

      final equipmentType = EquipmentType.fromJson(jsonBody);
      final createdEquipmentType = await _equipmentService.createType(equipmentType, userId);

      return Response.ok(jsonEncode(createdEquipmentType.toJson()), headers: {'Content-Type': 'application/json'});
    } catch (e) {
      return Response.internalServerError(body: '{"error": "Error creating equipment type: $e"}');
    }
  }

  Future<Response> _updateEquipmentType(Request request, String id) async {
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
      
      final equipmentType = EquipmentType.fromJson(jsonBody);
      final updatedEquipmentType = await _equipmentService.updateType(id, equipmentType, userId);

      return Response.ok(jsonEncode(updatedEquipmentType.toJson()), headers: {'Content-Type': 'application/json'});
    } catch (e) {
      return Response.internalServerError(body: '{"error": "Error updating equipment type: $e"}');
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

      await _db.equipmentTypes.archive(id, reason, userId);

      return Response.ok('{"status": "success"}');
    } catch (e) {
      return Response.internalServerError(
          body: '{"error": "Error archiving equipment type: $e"}');
    }
  }

  Future<Response> _unarchive(Request request, String id) async {
    try {
      await _db.equipmentTypes.unarchive(id);
      return Response.ok('{"status": "success"}');
    } catch (e) {
      return Response.internalServerError(
          body: '{"error": "Error unarchiving equipment type: $e"}');
    }
  }
}
