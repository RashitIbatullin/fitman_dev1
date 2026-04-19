import 'package:fitman_common/fitman_common.dart';
import 'base_api.dart';

/// Service class for administrator-specific APIs.
class AdminApiService extends BaseApiService {
  AdminApiService({super.client});

  Future<List<AnthropometryMeasurement>> getAnthropometryMeasurementsForClient(
      String clientId, {bool? includeArchived}) async {
    var endpoint = '/api/admin/clients/$clientId/anthropometry';
    if (includeArchived != null) {
      endpoint += '?includeArchived=$includeArchived';
    }
    final data = await get(endpoint) as List;
    return data.map((item) => AnthropometryMeasurement.fromJson(item)).toList();
  }

  Future<AnthropometryMeasurement> saveAnthropometryMeasurementForClient(
    String clientId,
    AnthropometryMeasurement measurement,
  ) async {
    final data = await post('/api/admin/clients/$clientId/anthropometry',
        body: measurement.toJson());
    return AnthropometryMeasurement.fromJson(data);
  }

  Future<AnthropometryFixed?> getFixedAnthropometryForClient(
      String clientId) async {
    final data =
        await getAllow404('/api/admin/clients/$clientId/anthropometry/fixed');
    if (data == null) return null;
    return AnthropometryFixed.fromJson(data);
  }

  Future<AnthropometryFixed> saveFixedAnthropometryForClient(
    String clientId,
    AnthropometryFixed fixedData,
  ) async {
    final data = await post(
        '/api/admin/clients/$clientId/anthropometry/fixed',
        body: fixedData.toJson());
    return AnthropometryFixed.fromJson(data);
  }

  Future<Map<String, dynamic>> getSomatotypeProfileForClient(String clientId) async {
    final data =
        await get('/api/admin/clients/$clientId/anthropometry/somatotype');
    return data;
  }

  Future<WhtrProfiles> getWhtrProfilesForClient(String clientId) async {
    final data =
        await get('/api/admin/clients/$clientId/anthropometry/whtr-profiles');
    return WhtrProfiles.fromJson(data);
  }

  Future<void> archiveAnthropometryMeasurement(
      String clientId, String measurementId, String reason) async {
    await post(
      '/api/admin/clients/$clientId/anthropometry/$measurementId/archive',
      body: {'reason': reason},
    );
  }

  Future<void> unarchiveAnthropometryMeasurement(
      String clientId, String measurementId) async {
    await put(
      '/api/admin/clients/$clientId/anthropometry/$measurementId/unarchive',
      body: {},
    );
  }

  Future<WhtrProfile> getWhtrForMeasurement(
      String clientId, String measurementId) async {
    final data = await get(
        '/api/admin/clients/$clientId/measurements/$measurementId/whtr');
    return WhtrProfile.fromJson(data);
  }
}
