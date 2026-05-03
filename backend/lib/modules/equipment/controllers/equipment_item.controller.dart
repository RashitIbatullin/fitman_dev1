import 'dart:convert';
import 'package:fitman_backend/config/database.dart';
import 'package:fitman_common/fitman_common.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_multipart/shelf_multipart.dart';
import '../../../services/photo_service.dart';

class EquipmentItemController {
  EquipmentItemController(this._db) {
    _router
      ..get('/', _getAllEquipmentItems)
      ..post('/', _createEquipmentItem)
      ..get('/<id>', _getById)
      ..put('/<id>', _updateEquipmentItem)
      ..put('/<id>/archive', _archive)
      ..put('/<id>/unarchive', _unarchive)
      ..post('/<id>/photos', _uploadPhoto)
      ..delete('/<id>/photos', _deletePhoto);
  }

  final Database _db;
  final _router = Router();
  final _photoService = PhotoService();


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
      final queryParams = request.url.queryParameters;
      final roomId = queryParams['roomId'];
      bool? includeArchived;
      if (queryParams.containsKey('includeArchived')) {
        includeArchived = queryParams['includeArchived'] == 'true';
      }

      late final List<EquipmentItem> equipmentItems;

      if (roomId != null && roomId.isNotEmpty) {
        equipmentItems = await _db.equipmentItems
            .getByRoomId(roomId, includeArchived: includeArchived);
      } else {
        equipmentItems =
            await _db.equipmentItems.getAll(includeArchived: includeArchived);
      }

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

      final userMap = request.context['user'] as Map<String, dynamic>;
      final user = User.fromJson(userMap);

      final equipmentItem = EquipmentItem.fromJson(jsonBody);
      final createdEquipmentItem =
          await _db.equipmentItems.create(equipmentItem, user.id);

      return Response.ok(jsonEncode(createdEquipmentItem.toJson()),
          headers: {'Content-Type': 'application/json'});
    } catch (e, s) {
      print('Error creating equipment item: $e, $s');
      if (e
          .toString()
          .contains('duplicate key value violates unique constraint')) {
        return Response.badRequest(
            body: '{"error": "Инвентарный номер уже существует"}');
      }
      return Response.internalServerError(
          body: '{"error": "Error creating equipment item: $e"}');
    }
  }

  Future<Response> _updateEquipmentItem(Request request, String id) async {
    try {
      final body = await request.readAsString();
      final Map<String, dynamic> jsonBody = jsonDecode(body) as Map<String, dynamic>;

      final userMap = request.context['user'] as Map<String, dynamic>;
      final user = User.fromJson(userMap);

      final equipmentItem = EquipmentItem.fromJson(jsonBody);
      final updatedEquipmentItem =
          await _db.equipmentItems.update(id, equipmentItem, user.id);

      return Response.ok(jsonEncode(updatedEquipmentItem.toJson()),
          headers: {'Content-Type': 'application/json'});
    } catch (e, s) {
      print('Error updating equipment item: $e, $s');
      if (e
          .toString()
          .contains('duplicate key value violates unique constraint')) {
        return Response.badRequest(
            body: '{"error": "Инвентарный номер уже существует"}');
      }
      return Response.internalServerError(
          body: '{"error": "Error updating equipment item: $e"}');
    }
  }

  Future<Response> _archive(Request request, String id) async {
    try {
      final body = await request.readAsString();
      final params = jsonDecode(body) as Map<String, dynamic>;
      final reason = params['reason'] as String?;
      final userMap = request.context['user'] as Map<String, dynamic>;
      final user = User.fromJson(userMap);

      if (reason == null || reason.length < 5) {
        return Response.badRequest(
          body:
              '{"error": "Archival reason must be at least 5 characters long."}',
        );
      }

      await _db.equipmentItems.archive(id, reason, user.id);

      return Response.ok('{"status": "success"}');
    } catch (e, s) {
      print('Error archiving equipment item: $e, $s');
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

  Future<Response> _uploadPhoto(Request request, String id) async {
    try {
      String? fileName;
      List<int>? fileBytes;

      if (request.formData() case final form?) {
        await for (final formData in form.formData) {
          if (formData.name == 'photo' && fileBytes == null) {
            fileName = formData.filename;
            fileBytes = await formData.part.readBytes();
          }
        }
      } else {
        return Response(400,
            body: jsonEncode({'error': 'Not a multipart/form-data request'}));
      }

      if (fileName == null || fileBytes == null) {
        return Response(400,
            body: jsonEncode(const <String, String>{'error': 'Missing "photo" part in multipart request.'}));
      }
      
      final publicUrl = await _photoService.savePhoto(
        subDirectory: 'equipment_photos',
        fileName: fileName,
        fileBytes: fileBytes,
      );

      await _db.equipmentItems.addPhotoUrl(id, publicUrl);

      return Response.ok(jsonEncode({'url': publicUrl}));
    } catch (e, s) {
      print('Error uploading equipment photo: $e, $s');
      return Response.internalServerError(
          body: '{"error": "Error uploading photo: $e"}');
    }
  }

  Future<Response> _deletePhoto(Request request, String id) async {
    try {
      final body = await request.readAsString();
      final jsonBody = jsonDecode(body);
      final photoUrl = jsonBody['photoUrl'] as String?;

      if (photoUrl == null) {
        return Response.badRequest(body: '{"error": "photoUrl is required."}');
      }

      await _db.equipmentItems.removePhotoUrl(id, photoUrl);
      await _photoService.deletePhotoFile(photoUrl);

      return Response.ok('{"status": "success"}');
    } catch (e, s) {
      print('Error deleting equipment photo: $e, $s');
      return Response.internalServerError(
          body: '{"error": "Error deleting photo: $e"}');
    }
  }
}
