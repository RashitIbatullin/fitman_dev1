import 'package:fitman_app/services/api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider to hold the state of the recommendation fetch operation
final recommendationProvider =
    FutureProvider.family<Map<String, dynamic>, int>((ref, clientId) async {
  try {
    final recommendation = await ApiService.getRecommendation(clientId);
    return recommendation;
  } catch (e) {
    // The error will be caught by the provider and can be handled in the UI
    rethrow;
  }
});
