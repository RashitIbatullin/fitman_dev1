import 'dart:convert';
import 'package:fitman_common/fitman_common.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_multipart/shelf_multipart.dart';
import 'package:shelf_router/shelf_router.dart';

import 'package:fitman_backend/modules/equipment/services/maintenance_service.dart';
import '../../../services/photo_service.dart';
import 'package:fitman_backend/errors/app_exception.dart';

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

      final user = request.context['user'] as User?;
      final userId = user?.id;
      if (userId == null) {
        return Response.forbidden(jsonEncode({'error': 'User not authenticated or userId is missing in token.'}));
      }

      final photoService = PhotoService();
      final photoUrl = await photoService.savePhoto(
        subDirectory: 'maintenance_photos',
        fileName: fileName,
        fileBytes: fileBytes,
      );

      await _maintenanceService.addPhoto(maintenanceId, photoUrl, comment ?? '', timing, userId);

      return Response.ok(jsonEncode({'message': "Photo uploaded successfully", "url": photoUrl}));

    } catch (error, stackTrace) {
      throw InternalException(cause: error, stackTrace: stackTrace);
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
      } catch (error, stackTrace) {
        throw InternalException(cause: error, stackTrace: stackTrace);
      }
    });

    router.get('/available-executors', (Request request) async {
      try {
        final executors = await _maintenanceService.getAvailableExecutors();
        return Response.ok(
          jsonEncode(executors),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (error, stackTrace) {
        throw InternalException(cause: error, stackTrace: stackTrace);
      }
    });

    router.get('/item/<itemId>', (Request request, String itemId) async {
      try {
        final includeArchived = request.url.queryParameters['includeArchived'] == 'true';
        final history = await _maintenanceService.getByEquipmentItemId(itemId, isArchived: includeArchived);
        final jsonResponse = jsonEncode(history.map((h) => h.toJson()).toList());
        return Response.ok(
          jsonResponse,
          headers: {'Content-Type': 'application/json'},
        );
      } catch (error, stackTrace) {
        throw InternalException(cause: error, stackTrace: stackTrace);
      }
    });

    router.get('/<id>', (Request request, String id) async {
      try {
        final history = await _maintenanceService.getById(id);
        final jsonResponse = jsonEncode(history.toJson());
        return Response.ok(
          jsonResponse,
          headers: {'Content-Type': 'application/json'},
        );
      } catch (error, stackTrace) {
        throw InternalException(cause: error, stackTrace: stackTrace);
      }
    });

    router.get('/<id>/status-history', (Request request, String id) async {
      try {
        final history = await _maintenanceService.getStatusHistory(id);
        final jsonResponse = jsonEncode(history);
        return Response.ok(
          jsonResponse,
          headers: {'Content-Type': 'application/json'},
        );
      } catch (error, stackTrace) {
        throw InternalException(cause: error, stackTrace: stackTrace);
      }
    });

    router.post('/', (Request request) async {
      try {
        final body = await request.readAsString();
        final jsonData = jsonDecode(body) as Map<String, dynamic>;
        
        final user = request.context['user'] as User?;
        final userId = user?.id;
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
      } catch (error, stackTrace) {
        throw InternalException(cause: error, stackTrace: stackTrace);
      }
    });

    router.post('/<id>/photos', _uploadPhoto);

    router.post('/<id>/diagnose', (Request request, String id) async {
      try {
        final body = await request.readAsString();
        final jsonData = jsonDecode(body) as Map<String, dynamic>;
        
        final user = request.context['user'] as User?;
        final userId = user?.id;
        if (userId == null) {
          return Response.forbidden(jsonEncode({'error': 'User not authenticated'}));
        }

        final diagnosisNotes = jsonData['diagnosis_notes'] as String?;
        if (diagnosisNotes == null || diagnosisNotes.isEmpty) {
          return Response.badRequest(body: jsonEncode({'error': 'diagnosis_notes is required'}));
        }
        final repairTimeStandardId = jsonData['repair_time_standard_id'] as String?;

        final updatedHistory = await _maintenanceService.submitDiagnosis(
          maintenanceId: id,
          userId: userId,
          diagnosisNotes: diagnosisNotes,
          repairTimeStandardId: repairTimeStandardId,
        );

        return Response.ok(
          jsonEncode(updatedHistory.toJson()),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (error, stackTrace) {
        throw InternalException(cause: error, stackTrace: stackTrace);
      }
    });

    router.post('/<id>/complete', (Request request, String id) async {
      try {
        final body = await request.readAsString();
        final jsonData = jsonDecode(body) as Map<String, dynamic>;

        final user = request.context['user'] as User?;
        final userId = user?.id;
        if (userId == null) {
          return Response.forbidden(jsonEncode({'error': 'User not authenticated'}));
        }

        final workDescription = jsonData['work_description'] as String?;
        if (workDescription == null || workDescription.isEmpty) {
          return Response.badRequest(body: jsonEncode({'error': 'work_description is required'}));
        }

        final updatedHistory = await _maintenanceService.completeRepair(
          maintenanceId: id,
          userId: userId,
          workDescription: workDescription,
        );
        return Response.ok(
          jsonEncode(updatedHistory.toJson()),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (error, stackTrace) {
        throw InternalException(cause: error, stackTrace: stackTrace);
      }
    });

    router.put('/<id>', (Request request, String id) async {
      try {
        final body = await request.readAsString();
        final jsonData = jsonDecode(body) as Map<String, dynamic>;
        final history = EquipmentMaintenanceHistory.fromJson(jsonData);
        
        final user = request.context['user'] as User?;
        final userId = user?.id;
        if (userId == null) {
          return Response.forbidden(jsonEncode({'error': 'User not authenticated or userId is missing in token.'}));
        }

        final updatedHistory = await _maintenanceService.update(id, history, userId);
        return Response.ok(
          jsonEncode(updatedHistory.toJson()),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (error, stackTrace) {
        throw InternalException(cause: error, stackTrace: stackTrace);
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
        
        final user = request.context['user'] as User?;
        final userId = user?.id;
        if (userId == null) {
          return Response.forbidden(jsonEncode({'error': 'User not authenticated or userId is missing in token.'}));
        }

        await _maintenanceService.archive(id, reason, userId);
        return Response.ok('{"message": "Record archived successfully"}');
      } catch (error, stackTrace) {
        throw InternalException(cause: error, stackTrace: stackTrace);
      }
    });

    router.put('/<id>/unarchive', (Request request, String id) async {
      try {
        await _maintenanceService.unarchive(id);
        return Response.ok('{"message": "Record unarchived successfully"}');
      } catch (error, stackTrace) {
        throw InternalException(cause: error, stackTrace: stackTrace);
      }
    });

    return router;
  }

  Handler get handler => router.call;
}
