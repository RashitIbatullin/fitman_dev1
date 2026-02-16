import 'dart:async';
import 'dart:convert';
import 'package:fitman_backend/config/database.dart';
import 'package:fitman_backend/modules/rooms/models/room/room.model.dart';
import 'package:fitman_backend/modules/rooms/repositories/room.repository.dart';
import 'package:fitman_backend/modules/rooms/services/room.service.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class RoomController {
  RoomController(Database db)
      : _roomService =
            RoomService(RoomRepositoryImpl(db));

  final RoomService _roomService;

  Router get router {
    final router = Router()
      ..get('/', _getRooms)
      ..post('/', _createRoom)
      ..get('/<id>', _getRoomById)
      ..put('/<id>', _updateRoom)
      ..delete('/<id>', _archiveRoom);
    return router;
  }

  Future<Response> _getRooms(Request request) async {
    final queryParams = request.url.queryParameters;
    final isArchived = queryParams['isArchived'] == null
        ? null
        : queryParams['isArchived'] == 'true';
    final isActive = queryParams['isActive'] == null
        ? null
        : queryParams['isActive'] == 'true';

    final rooms =
        await _roomService.getRooms(isArchived: isArchived, isActive: isActive);
    final roomsJson = rooms.map((r) => r.toJson()).toList();
    return Response.ok(jsonEncode(roomsJson));
  }

  Future<Response> _getRoomById(Request request, String id) async {
    try {
      final room = await _roomService.getRoomById(id);
      if (room == null) {
        return Response.notFound('{"error": "Room not found"}');
      }
      return Response.ok(jsonEncode(room.toJson()));
    } on Exception catch (e) {
      return Response.internalServerError(body: '{"error": "Error fetching room: $e"}');
    }
  }

  Future<Response> _createRoom(Request request) async {
    try {
      final body = await request.readAsString();
      final room = Room.fromJson(jsonDecode(body));
      final newRoom = await _roomService.createRoom(room);
      return Response(
        201,
        body: jsonEncode(newRoom.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } on Exception catch (e) {
      return Response.internalServerError(body: '{"error": "$e"}');
    }
  }

  Future<Response> _updateRoom(Request request, String id) async {
    try {
      // 1. Get user ID from context
      final userPayload = request.context['user'] as Map<String, dynamic>?;
      if (userPayload == null) {
        return Response.forbidden('{"error": "Authorization required. User payload missing."}');
      }
      final userId = userPayload['userId']?.toString();
      if (userId == null) {
        return Response.forbidden('{"error": "Authorization required. User ID missing."}');
      }

      // 2. Get initial Room object from request body
      final body = await request.readAsString();
      final initialRoom = Room.fromJson(jsonDecode(body));

      // 3. Create the final Room object with updated logic
      final Room finalRoom;
      final isArchiving = initialRoom.archivedAt != null;

      if (isArchiving) {
        // If archiving, set isActive to false and record who archived it
        finalRoom = Room(
          id: initialRoom.id,
          name: initialRoom.name,
          description: initialRoom.description,
          roomNumber: initialRoom.roomNumber,
          type: initialRoom.type,
          floor: initialRoom.floor,
          buildingId: initialRoom.buildingId,
          buildingName: initialRoom.buildingName,
          maxCapacity: initialRoom.maxCapacity,
          area: initialRoom.area,
          openTime: initialRoom.openTime,
          closeTime: initialRoom.closeTime,
          workingDays: initialRoom.workingDays,
          isActive: false, // Explicitly set to false on archive
          deactivateReason: initialRoom.deactivateReason,
          deactivateAt: initialRoom.deactivateAt,
          deactivateBy: initialRoom.deactivateBy,
          photoUrls: initialRoom.photoUrls,
          floorPlanUrl: initialRoom.floorPlanUrl,
          note: initialRoom.note,
          archivedAt: initialRoom.archivedAt,
          archivedReason: initialRoom.archivedReason,
          updatedBy: userId, // Record who updated
          archivedBy: userId, // Record who archived
        );
      } else {
        // If not archiving, just record who updated
        finalRoom = Room(
          id: initialRoom.id,
          name: initialRoom.name,
          description: initialRoom.description,
          roomNumber: initialRoom.roomNumber,
          type: initialRoom.type,
          floor: initialRoom.floor,
          buildingId: initialRoom.buildingId,
          buildingName: initialRoom.buildingName,
          maxCapacity: initialRoom.maxCapacity,
          area: initialRoom.area,
          openTime: initialRoom.openTime,
          closeTime: initialRoom.closeTime,
          workingDays: initialRoom.workingDays,
          isActive: initialRoom.isActive,
          deactivateReason: initialRoom.deactivateReason,
          deactivateAt: initialRoom.deactivateAt,
          deactivateBy: initialRoom.deactivateBy,
          photoUrls: initialRoom.photoUrls,
          floorPlanUrl: initialRoom.floorPlanUrl,
          note: initialRoom.note,
          archivedAt: initialRoom.archivedAt,
          archivedReason: initialRoom.archivedReason,
          updatedBy: userId, // Record who updated
          archivedBy: initialRoom.archivedBy, // Keep original value
        );
      }
      
      // 4. Call the service with the final Room object
      final updatedRoom = await _roomService.updateRoom(id, finalRoom);
      
      return Response.ok(
        jsonEncode(updatedRoom.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } on Exception catch (e) {
      return Response.internalServerError(body: '{"error": "$e"}');
    }
  }

  Future<Response> _archiveRoom(Request request, String id) async {
    try {
      final userPayload = request.context['user'] as Map<String, dynamic>?;
      if (userPayload == null) {
        return Response.forbidden('{"error": "Authorization required. User payload missing."}');
      }
      final userId = userPayload['userId']?.toString();
       if (userId == null) {
        return Response.forbidden('{"error": "Authorization required. User ID missing."}');
      }
      
      await _roomService.archiveRoom(id, userId);
      return Response(204);
    } on Exception catch (e) {
      return Response.internalServerError(body: '{"error": "$e"}');
    }
  }
}