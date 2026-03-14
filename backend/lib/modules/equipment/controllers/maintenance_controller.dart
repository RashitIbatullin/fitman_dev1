import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:shelf/shelf.dart';
import 'package:shelf_multipart/shelf_multipart.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:uuid/uuid.dart';

import 'package:fitman_backend/modules/equipment/models/equipment_maintenance_history.model.dart';
import 'package:fitman_backend/modules/equipment/services/maintenance_service.dart';

class MaintenanceController {
  MaintenanceController(this._maintenanceService);

  final MaintenanceService _maintenanceService;

  Future<Response> _uploadPhoto(Request request, String maintenanceId) async {
    try {
      String? fileName;
      String? comment;
      String? timing;
      List<int>? fileBytes;

      if (request.formData() case final form?) {
        await for (final formData in form.formData) {
          final fieldName = formData.name;
          if (fieldName == 'photo') {
            fileName = formData.filename;
            fileBytes = await formData.part.readBytes();
          } else if (fieldName == 'comment') {
            comment = await formData.part.readString();
          } else if (fieldName == 'timing') {
            timing = await formData.part.readString();
          }
        }
      } else {
        return Response.badRequest(body: jsonEncode({'error': 'Not a multipart/form-data request'}));
      }

      if (fileBytes == null || fileName == null || timing == null) {
        return Response.badRequest(body: jsonEncode({'error': "Missing required fields: 'photo', 'timing'"}));
      }

      final userPayload = request.context['user'] as Map<String, dynamic>?;
      final userId = userPayload?['userId']?.toString();
      if (userId == null) {
        return Response.forbidden(jsonEncode({'error': 'User not authenticated or userId is missing in token.'}));
      }

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

      return Response.ok(jsonEncode({'message': "Photo uploaded successfully", "url": photoUrl}));

    } catch (e, st) {
       print('--- BACKEND ERROR: _uploadPhoto ---');
       print('ERROR: $e');
       print('STACKTRACE: $st');
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
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
      } catch (e, st) {
        print('--- BACKEND ERROR: GET /maintenance ---');
        print('ERROR: $e');
        print('STACKTRACE: $st');
        return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
      }
    });

    router.get('/available-executors', (Request request) async {
      try {
        final executors = await _maintenanceService.getAvailableExecutors();
        return Response.ok(
          jsonEncode(executors),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e, st) {
        print('--- BACKEND ERROR: GET /maintenance/available-executors ---');
        print('ERROR: $e');
        print('STACKTRACE: $st');
        return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
      }
    });

    router.get('/item/<itemId>', (Request request, String itemId) async {
      try {
        final isArchived = request.url.queryParameters['isArchived'] == 'true';
        final history = await _maintenanceService.getByEquipmentItemId(itemId, isArchived: isArchived);
        final jsonResponse = jsonEncode(history.map((h) => h.toJson()).toList());
        return Response.ok(
          jsonResponse,
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e, st) {
        print('--- BACKEND ERROR: GET /maintenance/item/<itemId> ---');
        print('ERROR: $e');
        print('STACKTRACE: $st');
        return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
      }
    });

    router.post('/', (Request request) async {
      try {
        final body = await request.readAsString();
        final jsonData = jsonDecode(body) as Map<String, dynamic>;
        
        final userPayload = request.context['user'] as Map<String, dynamic>?;
        final userId = userPayload?['userId']?.toString();
        if (userId == null) {
          return Response.forbidden(jsonEncode({'error': 'User not authenticated or userId is missing in token.'}));
        }

        // --- Server-side validation for required client fields ---
        final equipmentItemId = jsonData['equipment_item_id'];
        if (equipmentItemId is! String || equipmentItemId.isEmpty) {
          return Response.badRequest(
            body: jsonEncode({'error': 'Field "equipment_item_id" must be a non-empty string'}),
          );
        }

        final reportedProblem = jsonData['reported_problem'];
        if (reportedProblem is! String || reportedProblem.isEmpty) {
          return Response.badRequest(
            body: jsonEncode({'error': 'Field "reported_problem" must be a non-empty string'}),
          );
        }
        
        final history = EquipmentMaintenanceHistory.fromJson(jsonData);

        final newHistory = await _maintenanceService.create(history, userId);
        return Response.ok(
          jsonEncode(newHistory.toJson()),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e, st) {
        print('--- BACKEND ERROR: POST /maintenance ---');
        print('ERROR: $e');
        print('STACKTRACE: $st');
        return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
      }
    });

    router.post('/<id>/photos', _uploadPhoto);

    router.put('/<id>', (Request request, String id) async {
      try {
        final body = await request.readAsString();
        final jsonData = jsonDecode(body) as Map<String, dynamic>;
        final history = EquipmentMaintenanceHistory.fromJson(jsonData);
        
        final userPayload = request.context['user'] as Map<String, dynamic>?;
        final userId = userPayload?['userId']?.toString();
        if (userId == null) {
          return Response.forbidden(jsonEncode({'error': 'User not authenticated or userId is missing in token.'}));
        }

        final updatedHistory = await _maintenanceService.update(id, history, userId);
        return Response.ok(
          jsonEncode(updatedHistory.toJson()),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e, st) {
        print('--- BACKEND ERROR: PUT /maintenance/<id> ---');
        print('ERROR: $e');
        print('STACKTRACE: $st');
        return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
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
        
        final userPayload = request.context['user'] as Map<String, dynamic>?;
        final userId = userPayload?['userId']?.toString();
        if (userId == null) {
          return Response.forbidden(jsonEncode({'error': 'User not authenticated or userId is missing in token.'}));
        }

        await _maintenanceService.archive(id, reason, userId);
        return Response.ok('{"message": "Record archived successfully"}');
      } catch (e, st) {
        print('--- BACKEND ERROR: DELETE /maintenance/<id> ---');
        print('ERROR: $e');
        print('STACKTRACE: $st');
        return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
      }
    });

    router.put('/<id>/unarchive', (Request request, String id) async {
      try {
        await _maintenanceService.unarchive(id);
        return Response.ok('{"message": "Record unarchived successfully"}');
      } catch (e) {
        print('--- BACKEND ERROR: PUT /maintenance/<id>/unarchive ---');
        print('ERROR: $e');
        return Response.internalServerError(body: jsonEncode({'error': 'Error unarchiving record: $e'}));
      }
    });

    return router;
  }

  Handler get handler => router.call;
}
