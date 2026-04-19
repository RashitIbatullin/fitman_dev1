import 'base_api.dart';

/// Service class for recommendation-related APIs.
class RecommendationApiService extends BaseApiService {
  RecommendationApiService({super.client});

  /// Fetches a recommendation for a client.
  Future<Map<String, dynamic>> getRecommendation(String clientId, {String? measurementId}) async {
    var endpoint = '/api/recommendations/$clientId';
    if (measurementId != null) {
      endpoint += '?measurement_id=$measurementId';
    }
    return await get(endpoint);
  }
}
