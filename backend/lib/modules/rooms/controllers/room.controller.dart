import 'dart:async';
import 'dart:convert';
import 'package:fitman_backend/config/database.dart';
import 'package:fitman_backend/modules/equipment/repositories/equipment_item.repository.dart';
import 'package:fitman_backend/modules/rooms/repositories/room.repository.dart';
import 'package:fitman_backend/modules/rooms/services/room.service.dart';
import 'package:fitman_common/modules/rooms/room.model.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class RoomController {
  RoomController(Database db)
      : _roomService = RoomService(
          RoomRepositoryImpl(db),
          EquipmentItemRepositoryImpl(db),
        );

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
      final room = await _roomService.getById(id);
      if (room == null) {
        return Response.notFound('{"error": "Room not found"}');
      }
      return Response.ok(jsonEncode(room.toJson()));
    } on Exception catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      return Response.internalServerError(body: '{"error": "Error fetching room: $errorMessage"}');
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
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      return Response.internalServerError(body: '{"error": "$errorMessage"}');
    }
  }

  Future<Response> _updateRoom(Request request, String id) async {
    try {
      // 1. Get user ID from context
      final userPayload = request.context['user'] as Map<String, dynamic>?;
      if (userPayload == null || userPayload['userId'] == null) {
        return Response.forbidden(
            '{"error": "Authorization required. User payload missing."}');
      }
      final userId = userPayload['userId'].toString();

      // 2. Decode the incoming room data
      final body = await request.readAsString();
      final incomingRoom = Room.fromJson(jsonDecode(body));

      // 3. Use copyWith to add server-side data (e.g., who updated it)
      final roomToUpdate = incomingRoom.copyWith(updatedBy: userId);

      // 4. Call the service with the robustly created object
      final updatedRoom = await _roomService.updateRoom(id, roomToUpdate);

      return Response.ok(
        jsonEncode(updatedRoom.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } on Exception catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      return Response.internalServerError(body: '{"error": "$errorMessage"}');
    }
  }

  Future<Response> _archiveRoom(Request request, String id) async {
    try {
      final userPayload = request.context['user'] as Map<String, dynamic>?;
      if (userPayload == null || userPayload['userId'] == null) {
        return Response.forbidden('{"error": "Authorization required. User ID missing."}');
      }
      final userId = userPayload['userId'].toString();

      await _roomService.archiveRoom(id, userId);
      return Response(204);
    } on Exception catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      return Response.internalServerError(body: '{"error": "$errorMessage"}');
    }
  }}