import 'dart:convert';
import 'package:fitman_common/fitman_common.dart';
import 'package:shelf/shelf.dart';
import '../../../config/database.dart';
import '../../../errors/app_exception.dart';

class CalorieTrackingController {
  static Future<Response> getCalorieTrackingDataForClient(Request request) async {
    try {
      final user = request.context['user'] as User?;
      if (user == null) {
        return Response.unauthorized(jsonEncode({'error': 'Not authenticated'}));
      }

      final clientId = user.id;
      final data = await Database().clients.getCalorieTrackingData(clientId);

      return Response.ok(jsonEncode(data));
    } catch (error, stackTrace) {
      throw InternalException(cause: error, stackTrace: stackTrace);
    }
  }
}
