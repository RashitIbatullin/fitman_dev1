import 'dart:async';
import 'dart:convert';

import 'package:fitman_backend/modules/rooms/room_providers.dart';
import 'package:fitman_backend/modules/rooms/services/room_service.dart';
import 'package:fitman_common/modules/rooms/room_model.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_multipart/shelf_multipart.dart';


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
      ..post('/<id>/photos', _uploadPhoto)
      ..delete('/<id>/photos', _deletePhoto); // ADDED ROUTE
    return router;
  }

  Future<shelf.Response> _uploadPhoto(shelf.Request request, String id) async {
    try {
      String? fileName;
      List<int>? fileBytes;

      if (request.formData() case final form?) {
        await for (final formData in form.formData) {
          if (formData.name == 'photo') {
            fileName = formData.filename;
            fileBytes = await formData.part.readBytes();
          }
        }
      } else {
        return shelf.Response(400,
            body: jsonEncode({'error': 'Not a multipart/form-data request'}));
      }

      if (fileName == null || fileBytes == null) {
        return shelf.Response(400,
            body: jsonEncode(const <String, String>{'error': 'Missing "photo" part in multipart request.'}));
      }

      final newPhotoUrl = await _roomService.uploadPhoto(
        roomId: id,
        fileName: fileName,
        fileBytes: fileBytes,
      );

      return shelf.Response.ok(jsonEncode({'url': newPhotoUrl}));
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      return shelf.Response.internalServerError(
          body: jsonEncode({'error': errorMessage}));
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
        return shelf.Response.notFound(jsonEncode({'error': 'Room not found'}));
      }
      return shelf.Response.ok(jsonEncode(room.toJson()));
    } on Exception catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      return shelf.Response.internalServerError(body: jsonEncode({'error': 'Error fetching room: $errorMessage'}));
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
      return shelf.Response.internalServerError(body: jsonEncode({'error': errorMessage}));
    }
  }

  Future<shelf.Response> _updateRoom(shelf.Request request, String id) async {
    try {
      // 1. Get user ID from context
      final userPayload = request.context['user'] as Map<String, dynamic>?;
      if (userPayload == null || userPayload['userId'] == null) {
        return shelf.Response.forbidden(
            jsonEncode({'error': 'Authorization required. User payload missing.'}));
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
      return shelf.Response.internalServerError(body: jsonEncode({'error': errorMessage}));
    }
  }

  Future<shelf.Response> _archiveRoom(shelf.Request request, String id) async {
    try {
      final userPayload = request.context['user'] as Map<String, dynamic>?;
      if (userPayload == null || userPayload['userId'] == null) {
        return shelf.Response.forbidden(jsonEncode({'error': 'Authorization required. User ID missing.'}));
      }
      final userId = userPayload['userId'].toString();

      await _roomService.archiveRoom(id, userId);
      return shelf.Response(204);
    } on Exception catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      return shelf.Response.internalServerError(body: jsonEncode({'error': errorMessage}));
    }
  }

  // ADDED METHOD
  Future<shelf.Response> _deletePhoto(shelf.Request request, String id) async {
    try {
      final body = await request.readAsString();
      final jsonData = jsonDecode(body) as Map<String, dynamic>;
      final photoUrl = jsonData['photoUrl'] as String?;

      if (photoUrl == null || photoUrl.isEmpty) {
        return shelf.Response.badRequest(
            body: jsonEncode(const <String, String>{'error': 'photoUrl is required in the request body.'}));
      }

      await _roomService.removeRoomPhoto(id, photoUrl);

      return shelf.Response.ok(jsonEncode({'message': 'Photo deleted successfully.'}));
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      return shelf.Response.internalServerError(
          body: jsonEncode({'error': errorMessage}));
    }
  }
}
