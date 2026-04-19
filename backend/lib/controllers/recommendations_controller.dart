import 'dart:convert';

import 'package:shelf/shelf.dart';

import '../services/recommendations/recommendation_service.dart';

class RecommendationsController {
  static Future<Response> getRecommendation(Request request, String id) async {
    try {
      // Basic authentication check from the context set by middleware
      final user = request.context['user'] as Map<String, dynamic>?;
      if (user == null) {
        return Response.unauthorized(jsonEncode({'error': 'Not authenticated'}));
      }

      final userId = id;
      final measurementId = request.url.queryParameters['measurement_id'];

      // Authorization could be added here:
      // e.g., check if the requesting user (user['userId']) is an admin, 
      // or a trainer for the client (userId), or the client themselves.
      // For now, we allow any authenticated user.

      final service = RecommendationService();
      final recommendation =
          await service.generateRecommendation(userId, measurementId: measurementId);

      if (recommendation['trainer_recommendation']!
          .contains('Недостаточно данных')) {
        return Response.notFound(
            jsonEncode({'error': recommendation['trainer_recommendation']}));
      }

      return Response.ok(jsonEncode(recommendation));
    } catch (e) {
      print('RecommendationsController error: $e');
      return Response.internalServerError(body: jsonEncode({'error': 'An internal error occurred.'}));
    }
  }
}
