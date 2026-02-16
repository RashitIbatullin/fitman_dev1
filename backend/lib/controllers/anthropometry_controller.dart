import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf_multipart/shelf_multipart.dart';
import '../config/database.dart';
import '../services/recommendations/recommendation_service.dart';

class AnthropometryController {
  static Future<Response> getSomatotype(Request request, [String? id]) async {
    try {
      final user = request.context['user'] as Map<String, dynamic>?;
      if (user == null) {
        return Response.unauthorized(jsonEncode({'error': 'Not authenticated'}));
      }
      
      int clientId;
      if (id != null) {
        clientId = int.parse(id);
      } else {
        clientId = user['userId'] as int;
      }

      final recommendationService = RecommendationService();
      final profile = await recommendationService.getSomatotypeProfileForUser(clientId);

      if (profile == null) {
        return Response.notFound(jsonEncode({'profile_string': 'Недостаточно данных для расчета соматотипа.'}));
      }

      return Response.ok(jsonEncode({'profile_string': profile.toString()}));

    } catch (e) {
      print('Get somatotype error: $e');
      return Response.internalServerError(body: jsonEncode({'error': 'Internal server error'}));
    }
  }

  static Future<Response> getAnthropometryDataForClient(Request request, [String? id]) async {
    try {
      final user = request.context['user'] as Map<String, dynamic>?;
      if (user == null) {
        return Response.unauthorized(jsonEncode({'error': 'Not authenticated'}));
      }

      int clientId;
      if (id != null) {
        clientId = int.parse(id);
      } else {
        clientId = user['userId'] as int;
      }
      print('[getAnthropometryDataForClient] Authenticated userId: ${user['userId']}, Using clientId: $clientId');
      final data = await Database().getAnthropometryData(clientId);

      return Response.ok(jsonEncode(data));
    } catch (e) {
      print('Get anthropometry data error: $e');
      return Response.internalServerError(body: jsonEncode({'error': 'Internal server error'}));
    }
  }

  static Future<Response> uploadPhoto(Request request, [String? id]) async {
    try {
      final user = request.context['user'] as Map<String, dynamic>?;
      if (user == null) {
        return Response.unauthorized(jsonEncode({'error': 'Not authenticated'}));
      }

      int clientId;
      if (id != null) {
        clientId = int.parse(id);
      } else {
        clientId = user['userId'] as int;
      }
      print('[uploadPhoto] Authenticated userId: ${user['userId']}, Using clientId: $clientId');

      String? type;
      String? fileName;
      List<int>? fileBytes;
      DateTime? photoDateTimeFromRequest;

      if (request.formData() case final form?) {
        await for (final formData in form.formData) {
          print('formData.name: ${formData.name}');
          print('formData.filename: ${formData.filename}');
          if (formData.name == 'type') {
            type = await formData.part.readString();
          } else if (formData.name == 'photo') {
            fileName = formData.filename;
            fileBytes = await formData.part.readBytes();
          } else if (formData.name == 'photoDateTime') {
            photoDateTimeFromRequest = DateTime.tryParse(await formData.part.readString());
          }
        }
      } else {
        return Response.badRequest(body: jsonEncode({'error': 'Not a multipart/form-data request'}));
      }

      if (type == null || fileName == null || fileBytes == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Missing required fields'}));
      }

      final uploadDir = Directory('../uploads');
      if (!await uploadDir.exists()) {
        await uploadDir.create(recursive: true);
      }

      final filePath = '${uploadDir.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(fileBytes);

      final photoUrl = '/uploads/$fileName';

      final now = photoDateTimeFromRequest ?? DateTime.now();
      final creatorId = user['userId'] as int;
      await Database().updateAnthropometryPhoto(clientId, photoUrl, type, now, creatorId);

      return Response.ok(jsonEncode({
        'url': photoUrl,
        'photo_date_time': now.toIso8601String(),
      }));
    } catch (e, s) {
      print('Upload photo error: $e');
      print(s);
      return Response.internalServerError(body: jsonEncode({'error': 'Internal server error'}));
    }
  }

  static Future<Response> updateFixedAnthropometry(Request request, [String? id]) async {
    try {
      final user = request.context['user'] as Map<String, dynamic>?;
      if (user == null) {
        return Response.unauthorized(jsonEncode({'error': 'Not authenticated'}));
      }

      int clientId;
      if (id != null) {
        clientId = int.parse(id);
      } else {
        clientId = user['userId'] as int;
      }
      print('[updateFixedAnthropometry] Authenticated userId: ${user['userId']}, Using clientId: $clientId');

      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final height = data['height'] as int?;
      final wristCirc = data['wristCirc'] as int?;
      final ankleCirc = data['ankleCirc'] as int?;

      final creatorId = user['userId'] as int;
      await Database().updateAnthropometryFixed(clientId, height, wristCirc, ankleCirc, creatorId);

      return Response.ok(jsonEncode({'message': 'Fixed anthropometry updated successfully'}));
    } catch (e, s) {
      print('Update fixed anthropometry error: $e');
      print(s);
      return Response.internalServerError(body: jsonEncode({'error': 'Internal server error'}));
    }
  }

  static Future<Response> updateMeasurementsAnthropometry(Request request, [String? id]) async {
    try {
      final user = request.context['user'] as Map<String, dynamic>?;
      if (user == null) {
        return Response.unauthorized(jsonEncode({'error': 'Not authenticated'}));
      }

      int clientId;
      if (id != null) {
        clientId = int.parse(id);
      } else {
        clientId = user['userId'] as int;
      }
      print('[updateMeasurementsAnthropometry] Authenticated userId: ${user['userId']}, Using clientId: $clientId');

      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final weight = (data['weight'] as num?)?.toDouble();
      final shouldersCirc = data['shouldersCirc'] as int?;
      final breastCirc = data['breastCirc'] as int?;
      final waistCirc = data['waistCirc'] as int?;
      final hipsCirc = data['hipsCirc'] as int?;

      final type = data['type'] as String; // 'start' or 'finish'

      if (type != 'start' && type != 'finish') {
        return Response.badRequest(body: jsonEncode({'error': 'Invalid anthropometry type. Must be \'start\' or \'finish\''}));
      }

      final creatorId = user['userId'] as int;
      await Database().updateAnthropometryMeasurements(
        clientId,
        type,
        weight,
        shouldersCirc,
        breastCirc,
        waistCirc,
        hipsCirc,
        creatorId,
      );

      return Response.ok(jsonEncode({'message': 'Measurements anthropometry updated successfully'}));
    } catch (e, s) {
      print('Update measurements anthropometry error: $e');
      print(s);
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    }
  }

  static Future<Response> getWhtrProfiles(Request request, [String? id]) async {
    try {
      final user = request.context['user'] as Map<String, dynamic>?;
      if (user == null) {
        return Response.unauthorized(jsonEncode({'error': 'Not authenticated'}));
      }
      
      int clientId;
      if (id != null) {
        clientId = int.parse(id);
      } else {
        clientId = user['userId'] as int;
      }

      final recommendationService = RecommendationService();
      final profiles = await recommendationService.getWhtrProfilesForUser(clientId);

      if (profiles == null) {
        return Response.notFound(jsonEncode({'error': 'Could not calculate WHtR profiles. User not found or missing anthropometry data.'}));
      }

      return Response.ok(jsonEncode(profiles.toJson()));

    } catch (e) {
      print('Get WHtR profiles error: $e');
      return Response.internalServerError(body: jsonEncode({'error': 'Internal server error'}));
    }
  }
}