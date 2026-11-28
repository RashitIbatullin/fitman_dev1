import 'package:fitman_common/fitman_common.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/api/services_api.dart';

/// Услуги конкретного клиента: остатки, сроки и статусы.
final clientServicesProvider =
    FutureProvider.autoDispose.family<List<ServicePurchase>, String>(
  (ref, clientId) async {
    final api = ServicesApiService();
    try {
      return await api.getClientServices(clientId);
    } catch (error) {
      throw Exception('Не удалось загрузить услуги: $error');
    }
  },
);

/// Активный каталог услуг для диалога оформления.
final activeServicesProvider = FutureProvider.autoDispose<List<Service>>(
  (ref) async {
    final api = ServicesApiService();
    try {
      return await api.getServices(active: true);
    } catch (error) {
      throw Exception('Не удалось загрузить каталог услуг: $error');
    }
  },
);
