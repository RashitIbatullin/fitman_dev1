import 'base_api.dart';

/// Service class for recommendation-related APIs.
class RecommendationApiService extends BaseApiService {
  RecommendationApiService({super.client});

  /// Fetches a recommendation for a client.
  Future<Map<String, dynamic>> getRecommendation(int clientId) async {
    return await get('/api/recommendations/$clientId');
  }
}
