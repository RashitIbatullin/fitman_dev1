import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:shelf/shelf.dart';
import 'package:mime/mime.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:uuid/uuid.dart';
import 'package:fitman_backend/modules/maintenance/models/equipment_maintenance_history.model.dart';
import 'package:fitman_backend/modules/maintenance/services/maintenance_service.dart';

class MaintenanceController {
  MaintenanceController(this._maintenanceService);

  final MaintenanceService _maintenanceService;

  Future<Response> _uploadPhoto(Request request, String maintenanceId) async {
    try {
      final boundary = request.headers['content-type']!;
      final transformer = MimeMultipartTransformer(boundary);
      final body = request.read();
      final parts = await transformer.bind(body).toList();

      String? fileName;
      String? comment;
      String? timing;
      List<int>? fileBytes;

      for (final part in parts) {
        final contentDisposition = part.headers['content-disposition'];
        if (contentDisposition == null) continue;
        
        final fieldName = RegExp(r'name="([^"]*)"').firstMatch(contentDisposition)?.group(1);

        if (fieldName == 'photo') {
          fileName = RegExp(r'filename="([^"]*)"').firstMatch(contentDisposition)?.group(1);
          final builder = await part.fold<BytesBuilder>(BytesBuilder(), (builder, d) => builder..add(d));
          fileBytes = builder.takeBytes();

        } else if (fieldName == 'comment') {
          final data = await part.cast<List<int>>().transform(utf8.decoder).join();
          comment = data;
        } else if (fieldName == 'timing') {
          final data = await part.cast<List<int>>().transform(utf8.decoder).join();
          timing = data;
        }
      }


      if (fileBytes == null || fileName == null || timing == null) {
        return Response.badRequest(body: '{"error": "Missing required fields: photo, timing"}');
      }

      final userId = request.context['user_id'] as String;
      final fileExtension = p.extension(fileName);
      final newFileName = '${const Uuid().v4()}$fileExtension';
      
      final uploadPath = p.normalize(p.join(Directory.current.path, '..', 'uploads', 'maintenance_photos'));
      final filePath = p.join(uploadPath, newFileName);

      final uploadDir = Directory(uploadPath);
      if (!await uploadDir.exists()) {
        await uploadDir.create(recursive: true);
      }

      await File(filePath).writeAsBytes(fileBytes);

      final photoUrl = '/uploads/maintenance_photos/$newFileName';

      await _maintenanceService.addPhoto(maintenanceId, photoUrl, comment ?? '', timing, userId);

      return Response.ok('{"message": "Photo uploaded successfully", "url": "$photoUrl"}');

    } catch (e) {
      return Response.internalServerError(body: '{"error": "$e"}');
    }
  }

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

    router.post('/<id>/photos', _uploadPhoto);

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
