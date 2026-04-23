import 'package:fitman_common/fitman_common.dart';

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

  /// Fetches the calculated BMR and TDEE for a client based on a specific measurement.
  Future<MetabolicProfile> getMetabolicRate(String clientId, String measurementId) async {
    final endpoint = '/api/clients/$clientId/measurements/$measurementId/metabolic-rate';
    final json = await get(endpoint);
    return MetabolicProfile.fromJson(json);
  }
}
