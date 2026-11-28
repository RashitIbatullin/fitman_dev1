import 'package:fitman_common/fitman_common.dart';

import 'base_api.dart';

/// Каталог услуг, оформление и остатки.
class ServicesApiService extends BaseApiService {
  ServicesApiService({super.client});

  /// Каталог услуг с фильтрами по типу и активности.
  Future<List<Service>> getServices({
    String? type,
    bool? active,
    bool? archived,
  }) async {
    final query = <String, String>{};
    if (type != null && type.isNotEmpty) query['type'] = type;
    if (active != null) query['active'] = active.toString();
    if (archived != null) query['archived'] = archived.toString();

    final data = await get(
      '/api/services',
      queryParams: query.isEmpty ? null : query,
    );
    final items = data as List<dynamic>;
    return items
        .map((item) => Service.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Service> getServiceById(String id) async {
    final data = await get('/api/services/$id');
    return Service.fromJson(data as Map<String, dynamic>);
  }

  /// Справочник типов услуг.
  Future<List<Map<String, dynamic>>> getServiceTypes() async {
    final data = await get('/api/services/types');
    return (data as List<dynamic>).cast<Map<String, dynamic>>();
  }

  /// Справочник специализаций исполнителей.
  Future<List<Map<String, dynamic>>> getSpecializations() async {
    final data = await get('/api/services/specializations');
    return (data as List<dynamic>).cast<Map<String, dynamic>>();
  }

  Future<Service> createService(Map<String, dynamic> data) async {
    final created = await post('/api/services', body: data);
    return Service.fromJson(created as Map<String, dynamic>);
  }

  Future<Service> updateService(
    String id,
    Map<String, dynamic> data,
  ) async {
    final updated = await put('/api/services/$id', body: data);
    return Service.fromJson(updated as Map<String, dynamic>);
  }

  Future<Service> archiveService(String id, {required String reason}) async {
    final archived = await post(
      '/api/services/$id/archive',
      body: {'reason': reason},
    );
    return Service.fromJson(archived as Map<String, dynamic>);
  }

  Future<Service> unarchiveService(String id) async {
    final restored = await post(
      '/api/services/$id/unarchive',
      body: const {},
    );
    return Service.fromJson(restored as Map<String, dynamic>);
  }

  /// Оформляет услугу клиенту.
  Future<ServicePurchase> createPurchase({
    required String clientId,
    required String serviceId,
    int? paymentSource,
    double? discount,
    double? discountPercent,
  }) async {
    final data = await post(
      '/api/service-purchases',
      body: {
        'clientId': clientId,
        'serviceId': serviceId,
        'paymentSource': ?paymentSource,
        if (discount != null && discount > 0) 'discount': discount,
        if (discountPercent != null && discountPercent > 0)
          'discountPercent': discountPercent,
      },
    );
    return ServicePurchase.fromJson(data as Map<String, dynamic>);
  }

  /// Активирует отложенную покупку.
  Future<ServicePurchase> activatePurchase(String purchaseId) async {
    final data = await post(
      '/api/service-purchases/$purchaseId/activate',
      body: const {},
    );
    return ServicePurchase.fromJson(data as Map<String, dynamic>);
  }

  /// Ручная архивация покупки сотрудником.
  Future<ServicePurchase> archivePurchase(
    String purchaseId, {
    required String reason,
  }) async {
    final data = await post(
      '/api/service-purchases/$purchaseId/archive',
      body: {'reason': reason},
    );
    return ServicePurchase.fromJson(data as Map<String, dynamic>);
  }

  Future<ServicePurchase> unarchivePurchase(String purchaseId) async {
    final data = await post(
      '/api/service-purchases/$purchaseId/unarchive',
      body: const {},
    );
    return ServicePurchase.fromJson(data as Map<String, dynamic>);
  }

  /// Активные и истёкшие услуги клиента.
  Future<List<ServicePurchase>> getClientServices(String clientId) async {
    final data = await get('/api/clients/$clientId/services');
    final items = data as List<dynamic>;
    return items
        .map((item) => ServicePurchase.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// История покупок клиента.
  Future<List<ServicePurchase>> getServicePurchases({
    String? clientId,
    int? status,
  }) async {
    final query = <String, String>{};
    if (clientId != null && clientId.isNotEmpty) query['clientId'] = clientId;
    if (status != null) query['status'] = status.toString();

    final data = await get(
      '/api/service-purchases',
      queryParams: query.isEmpty ? null : query,
    );
    final items = data as List<dynamic>;
    return items
        .map((item) => ServicePurchase.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
