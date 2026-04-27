import 'dart:async';
import 'dart:convert';

import 'package:fitman_backend/modules/rooms/room_providers.dart';
import 'package:fitman_backend/modules/rooms/services/room_service.dart';
import 'package:fitman_common/modules/rooms/room.model.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf_router/shelf_router.dart';


class RoomController {
  RoomController() : _roomService = RoomProviders().roomService;

  final RoomService _roomService;

  Router get router {
    final router = Router()
      ..get('/', _getRooms)
      ..post('/', _createRoom)
      ..get('/<id>', _getRoomById)
      ..put('/<id>', _updateRoom)
      ..delete('/<id>', _archiveRoom)
      ..post('/<id>/photos', _uploadPhoto);
    return router;
  }

  Future<shelf.Response> _uploadPhoto(shelf.Request request, String id) async {
    try {
      if (!request.isMultipart) {
        return shelf.Response(400, body: '{"error": "Expected a multipart request."}');
      }

      String? fileName;
      List<int>? fileBytes;

      await for (final part in request.parts) {
        if (part.name == 'photo') {
          fileBytes = await part.readBytes();
          fileName = part.filename;
        }
      }

      if (fileName == null || fileBytes == null) {
        return shelf.Response(400, body: '{"error": "Missing "photo" part in multipart request."}');
      }

      final newPhotoUrl = await _roomService.uploadPhoto(
        roomId: id,
        fileName: fileName,
        fileBytes: fileBytes,
      );

      return shelf.Response.ok(jsonEncode({'url': newPhotoUrl}));
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      return shelf.Response.internalServerError(body: '{"error": "$errorMessage"}');
    }
  }

  Future<shelf.Response> _getRooms(shelf.Request request) async {
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
    return shelf.Response.ok(jsonEncode(roomsJson));
  }

  Future<shelf.Response> _getRoomById(shelf.Request request, String id) async {
    try {
      final room = await _roomService.getById(id);
      if (room == null) {
        return shelf.Response.notFound('{"error": "Room not found"}');
      }
      return shelf.Response.ok(jsonEncode(room.toJson()));
    } on Exception catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      return shelf.Response.internalServerError(body: '{"error": "Error fetching room: $errorMessage"}');
    }
  }

  Future<shelf.Response> _createRoom(shelf.Request request) async {
    try {
      final body = await request.readAsString();
      final room = Room.fromJson(jsonDecode(body));
      final newRoom = await _roomService.createRoom(room);
      return shelf.Response(
        201,
        body: jsonEncode(newRoom.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } on Exception catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      return shelf.Response.internalServerError(body: '{"error": "$errorMessage"}');
    }
  }

  Future<shelf.Response> _updateRoom(shelf.Request request, String id) async {
    try {
      // 1. Get user ID from context
      final userPayload = request.context['user'] as Map<String, dynamic>?;
      if (userPayload == null || userPayload['userId'] == null) {
        return shelf.Response.forbidden(
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

      return shelf.Response.ok(
        jsonEncode(updatedRoom.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } on Exception catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      return shelf.Response.internalServerError(body: '{"error": "$errorMessage"}');
    }
  }

  Future<shelf.Response> _archiveRoom(shelf.Request request, String id) async {
    try {
      final userPayload = request.context['user'] as Map<String, dynamic>?;
      if (userPayload == null || userPayload['userId'] == null) {
        return shelf.Response.forbidden('{"error": "Authorization required. User ID missing."}');
      }
      final userId = userPayload['userId'].toString();

      await _roomService.archiveRoom(id, userId);
      return shelf.Response(204);
    } on Exception catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      return shelf.Response.internalServerError(body: '{"error": "$errorMessage"}');
    }
  }}