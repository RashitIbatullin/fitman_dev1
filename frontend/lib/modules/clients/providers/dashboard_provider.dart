import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitman_common/fitman_common.dart';
import '../../../services/api_service.dart';

final dashboardDataProvider =
    FutureProvider.autoDispose.family<DashboardData, String>((ref, userId) async {
  // No need to check auth role here, the backend will handle authorization.
  final data = await ApiService.getClientDashboardData(userId);
  return DashboardData.fromJson(data);
});
