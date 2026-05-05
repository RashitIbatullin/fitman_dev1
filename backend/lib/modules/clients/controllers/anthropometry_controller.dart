import 'dart:convert';
import 'package:fitman_common/fitman_common.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_multipart/shelf_multipart.dart';
import '../../../config/database.dart';
import '../../../services/recommendations/recommendation_service.dart';
import '../../../services/photo_service.dart';

class AnthropometryController {
  static Future<Response> getSomatotype(Request request, [String? id]) async {
    try {
      final user = request.context['user'] as User?;
      if (user == null) {
        return Response.unauthorized(jsonEncode({'error': 'Not authenticated'}));
      }

      String clientId;
      if (id != null) {
        clientId = id;
      } else {
        clientId = user.id;
      }

      final recommendationService = RecommendationService();
      final somatotypeProfile =
          await recommendationService.getSomatotypeProfileForUser(clientId);
      final bodyShape = await recommendationService.getBodyShapeForUser(clientId);

      if (somatotypeProfile == null) {
        return Response.notFound(jsonEncode(
            {'error': 'Недостаточно данных для расчета соматотипа.'}));
      }

      return Response.ok(jsonEncode({
        'somatotype_profile': somatotypeProfile.toString(),
        'body_shape': bodyShape,
      }));
    } catch (e, s) {
      print('Get somatotype error: $e');
      print(s);
      return Response.internalServerError(
          body: jsonEncode({'error': e.toString(), 'stackTrace': s.toString()}));
    }
  }

  // Methods for periodic measurements
  static Future<Response> getAnthropometry(Request request,
      [String? id]) async {
    try {
      final user = request.context['user'] as User?;
      if (user == null) {
        return Response.unauthorized(jsonEncode({'error': 'Not authenticated'}));
      }
      final clientId = id ?? user.id;
      final includeArchived =
          request.url.queryParameters['includeArchived'] == 'true';

      final data = await Database().clients.getAnthropometryMeasurements(
            clientId,
            includeArchived: includeArchived,
          );
      return Response.ok(jsonEncode(data));
    } catch (e) {
      print('Get anthropometry data error: $e');
      return Response.internalServerError(
          body: jsonEncode({'error': 'Internal server error'}));
    }
  }

  static Future<Response> saveAnthropometry(Request request,
      [String? id]) async {
    try {
      final user = request.context['user'] as User?;
      if (user == null) {
        return Response.unauthorized(jsonEncode({'error': 'Not authenticated'}));
      }
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final measurement = AnthropometryMeasurement.fromJson(data);
      final authorizedClientId = id ?? user.id;
      if (measurement.userId != authorizedClientId) {
        return Response.forbidden(
            jsonEncode({'error': 'Mismatched user ID'}));
      }
      final updatedMeasurement = measurement.copyWith(
        updatedBy: user.id,
        createdBy: measurement.id == null ? user.id : measurement.createdBy,
      );
      final savedMeasurement = await Database()
          .clients
          .saveAnthropometryMeasurement(updatedMeasurement);
      return Response.ok(jsonEncode(savedMeasurement));
    } catch (e, s) {
      print('Save anthropometry error: $e');
      print(s);
      return Response.internalServerError(
          body: jsonEncode({'error': e.toString()}));
    }
  }

  static Future<Response> archiveAnthropometryMeasurement(
      Request request, String clientId, String measurementId) async {
    try {
      final user = request.context['user'] as User?;
      if (user == null) {
        return Response.unauthorized(jsonEncode({'error': 'Not authenticated'}));
      }
      final userId = user.id;
      
      final body = await request.readAsString();
      if (body.isEmpty) {
        return Response.badRequest(body: jsonEncode({'error': 'Missing reason in request body'}));
      }
      final data = jsonDecode(body) as Map<String, dynamic>;
      final reason = data['reason'] as String?;

      if (reason == null || reason.trim().length < 5) {
        return Response.badRequest(body: jsonEncode({'error': 'Reason must be at least 5 characters long'}));
      }

      await Database()
          .clients
          .archiveAnthropometryMeasurement(measurementId, userId, reason);

      return Response(204); // No Content
    } catch (e) {
      print('Archive anthropometry measurement error: $e');
      return Response.internalServerError(
          body: jsonEncode({'error': 'Internal server error'}));
    }
  }

  static Future<Response> unarchiveAnthropometryMeasurement(
      Request request, String clientId, String measurementId) async {
    try {
      await Database().clients.unarchiveAnthropometryMeasurement(measurementId);
      return Response(204); // No Content
    } catch (e) {
      print('Unarchive anthropometry measurement error: $e');
      return Response.internalServerError(
          body: jsonEncode({'error': 'Internal server error'}));
    }
  }

  // Methods for fixed data
  static Future<Response> getFixedAnthropometry(Request request, [String? id]) async {
    try {
      final user = request.context['user'] as User?;
      if (user == null) {
        return Response.unauthorized(jsonEncode({'error': 'Not authenticated'}));
      }
      final clientId = id ?? user.id;
      final data = await Database().clients.getFixedAnthropometry(clientId);
      if (data == null) {
        return Response.notFound(jsonEncode({'message': 'No fixed data found for user'}));
      }
      return Response.ok(jsonEncode(data));
    } catch (e) {
      print('Get fixed anthropometry error: $e');
      return Response.internalServerError(body: jsonEncode({'error': 'Internal server error'}));
    }
  }

  static Future<Response> saveFixedAnthropometry(Request request, [String? id]) async {
    try {
      final user = request.context['user'] as User?;
      if (user == null) {
        return Response.unauthorized(jsonEncode({'error': 'Not authenticated'}));
      }
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final fixedData = AnthropometryFixed.fromJson(data);
       final authorizedClientId = id ?? user.id;
      if (fixedData.userId != authorizedClientId) {
        return Response.forbidden(
            jsonEncode({'error': 'Mismatched user ID'}));
      }
      final updatedFixedData = fixedData.copyWith(
        updatedBy: user.id,
        createdBy: fixedData.createdBy ?? user.id,
      );
      final savedData = await Database().clients.saveFixedAnthropometry(updatedFixedData);
      return Response.ok(jsonEncode(savedData));
    } catch (e) {
      print('Save fixed anthropometry error: $e');
      return Response.internalServerError(body: jsonEncode({'error': 'Internal server error'}));
    }
  }

  static Future<Response> uploadPhoto(Request request) async {
    try {
      final user = request.context['user'] as User?;
      if (user == null) {
        return Response.unauthorized(jsonEncode({'error': 'Not authenticated'}));
      }

      String? fileName;
      List<int>? fileBytes;
      if (request.formData() case final form?) {
        await for (final formData in form.formData) {
          if (formData.name == 'photo') {
            fileName = formData.filename;
            fileBytes = await formData.part.readBytes();
            break;
          }
        }
      } else {
        return Response.badRequest(body: jsonEncode({'error': 'Not a multipart/form-data request'}));
      }

      if (fileName == null || fileBytes == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Missing photo file'}));
      }

      final photoService = PhotoService();
      final photoUrl = await photoService.savePhoto(
        subDirectory: 'anthropometry_photos',
        fileName: fileName,
        fileBytes: fileBytes,
      );

      return Response.ok(jsonEncode({
        'url': photoUrl,
      }));
    } catch (e, s) {
      print('Upload photo error: $e');
      print(s);
      return Response.internalServerError(
          body: jsonEncode({'error': 'Internal server error'}));
    }
  }

  
  static Future<Response> getWhtrProfiles(Request request,
      [String? id]) async {
    try {
      final user = request.context['user'] as User?;
      if (user == null) {
        return Response.unauthorized(jsonEncode({'error': 'Not authenticated'}));
      }
      String clientId;
      if (id != null) {
        clientId = id;
      } else {
        clientId = user.id;
      }
      final recommendationService = RecommendationService();
      final profiles =
          await recommendationService.getWhtrProfilesForUser(clientId);
      if (profiles == null) {
        return Response.notFound(jsonEncode({
          'error':
              'Could not calculate WHtR profiles. User not found or missing anthropometry data.'
        }));
      }
      return Response.ok(jsonEncode(profiles.toJson()));
    } catch (e, s) {
      print('Get WHtR profiles error: $e');
      print(s);
      return Response.internalServerError(
          body: jsonEncode({'error': e.toString(), 'stackTrace': s.toString()}));
    }
  }

  static Future<Response> getWhtrForMeasurement(
      Request request, String measurementId) async {
    try {
      final recommendationService = RecommendationService();
      final profile =
          await recommendationService.getWhtrForMeasurement(measurementId);

      if (profile == null) {
        return Response.notFound(jsonEncode({
          'error':
              'Could not calculate WHtR profile. Measurement not found or missing fixed data.'
        }));
      }
      return Response.ok(jsonEncode(profile.toJson()));
    } catch (e, s) {
      print('Get WHtR for measurement error: $e');
      print(s);
      return Response.internalServerError(
          body: jsonEncode({'error': e.toString(), 'stackTrace': s.toString()}));
    }
  }
}
