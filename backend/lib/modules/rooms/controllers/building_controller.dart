import 'dart:async';
import 'dart:convert';
import 'package:fitman_backend/modules/rooms/models/building/building.model.dart';
import 'package:fitman_backend/modules/rooms/services/building_service.dart';
import 'package:fitman_backend/modules/rooms/repositories/building_repository.dart';
import 'package:fitman_backend/config/database.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class BuildingController {
  BuildingController(Database db)
      : _buildingService =
            BuildingService(BuildingRepository(db));

  final BuildingService _buildingService;

  Router get router {
    final router = Router()
      ..get('/', _getBuildings)
      ..post('/', _createBuilding)
      ..get('/<id>', _getBuildingById)
      ..put('/<id>', _updateBuilding)
      ..delete('/<id>', _deleteBuilding);
    return router;
  }

  Future<Response> _getBuildings(Request request) async {
    final queryParams = request.url.queryParameters;
    final isArchived = queryParams['isArchived'] == null
        ? null
        : queryParams['isArchived'] == 'true';

    final buildings = await _buildingService.getBuildings(isArchived: isArchived);
    return Response.ok(
      jsonEncode(buildings.map((e) => e.toJson()).toList()),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<Response> _getBuildingById(Request request, String id) async {
    final building = await _buildingService.getBuildingById(id);
    if (building == null) {
      return Response.notFound('Building not found');
    }
    return Response.ok(
      jsonEncode(building.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<Response> _createBuilding(Request request) async {
    try {
      final body = await request.readAsString();
      final building = Building.fromJson(jsonDecode(body));
      final newBuilding = await _buildingService.createBuilding(building);
      return Response(
        201,
        body: jsonEncode(newBuilding.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } on Exception catch (e) {
      if (e.toString().contains('Building with this name already exists')) {
        return Response(409, body: '{"error": "Здание с таким названием уже существует"}');
      }
      return Response.internalServerError(body: '{"error": "$e"}');
    }
  }

  Future<Response> _updateBuilding(Request request, String id) async {
    try {
      final userPayload = request.context['user'] as Map<String, dynamic>?;
      if (userPayload == null) {
        return Response.forbidden('{"error": "Authorization required. User payload missing."}');
      }
      final userId = userPayload['userId']?.toString();
      if (userId == null) {
        return Response.forbidden('{"error": "Authorization required. User ID missing."}');
      }

      final body = await request.readAsString();
      final initialBuilding = Building.fromJson(jsonDecode(body));

      final Building finalBuilding;
      final isArchiving = initialBuilding.archivedAt != null;

      if (isArchiving) {
        finalBuilding = Building(
          id: initialBuilding.id,
          name: initialBuilding.name,
          address: initialBuilding.address,
          note: initialBuilding.note,
          createdAt: initialBuilding.createdAt,
          updatedAt: initialBuilding.updatedAt,
          createdBy: initialBuilding.createdBy,
          updatedBy: userId,
          archivedAt: initialBuilding.archivedAt,
          archivedBy: userId,
          archivedByName: initialBuilding.archivedByName,
          archivedReason: initialBuilding.archivedReason,
        );
      } else {
        finalBuilding = Building(
          id: initialBuilding.id,
          name: initialBuilding.name,
          address: initialBuilding.address,
          note: initialBuilding.note,
          createdAt: initialBuilding.createdAt,
          updatedAt: initialBuilding.updatedAt,
          createdBy: initialBuilding.createdBy,
          updatedBy: userId,
          archivedAt: initialBuilding.archivedAt,
          archivedBy: initialBuilding.archivedBy,
          archivedByName: initialBuilding.archivedByName,
          archivedReason: initialBuilding.archivedReason,
        );
      }

      final updatedBuilding = await _buildingService.updateBuilding(id, finalBuilding, userId);
      return Response.ok(
        jsonEncode(updatedBuilding.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } on Exception catch (e) {
      return Response.internalServerError(body: '{"error": "$e"}');
    }
  }

  Future<Response> _deleteBuilding(Request request, String id) async {
    try {
      final userPayload = request.context['user'] as Map<String, dynamic>?;
      if (userPayload == null) {
        return Response(401, body: jsonEncode({'error': 'Not authenticated: User payload missing.'}));
      }
      final userId = userPayload['userId'] as int?;
      if (userId == null) {
        return Response(401, body: jsonEncode({'error': 'Not authenticated: User ID missing in token.'}));
      }

      await _buildingService.deleteBuilding(id, userId);
      return Response(204);
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    }
  }
}
