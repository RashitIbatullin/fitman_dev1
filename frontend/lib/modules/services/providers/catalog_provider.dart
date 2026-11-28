import 'package:fitman_common/fitman_common.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/api/services_api.dart';

/// Каталог услуг: `false` — действующие, `true` — архив.
final serviceCatalogProvider =
    FutureProvider.autoDispose.family<List<Service>, bool>(
  (ref, archived) async {
    try {
      return await ServicesApiService().getServices(archived: archived);
    } catch (error) {
      throw Exception('Не удалось загрузить услуги: $error');
    }
  },
);

/// Карточка услуги по id.
final serviceByIdProvider =
    FutureProvider.autoDispose.family<Service, String>((ref, id) async {
  try {
    return await ServicesApiService().getServiceById(id);
  } catch (error) {
    throw Exception('Не удалось загрузить услугу: $error');
  }
});

/// Типы услуг для фильтра и формы.
final serviceTypesProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  try {
    return await ServicesApiService().getServiceTypes();
  } catch (error) {
    throw Exception('Не удалось загрузить типы услуг: $error');
  }
});

/// Специализации исполнителей для формы услуги.
final serviceSpecializationsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  try {
    return await ServicesApiService().getSpecializations();
  } catch (error) {
    throw Exception('Не удалось загрузить специализации: $error');
  }
});
