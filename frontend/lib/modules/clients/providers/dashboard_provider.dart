import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitman_common/fitman_common.dart';
import '../../../services/api_service.dart';

final dashboardDataProvider = FutureProvider<DashboardData>((ref) async {
  final data = await ApiService.getClientDashboardData();
  return DashboardData.fromJson(data);
});
