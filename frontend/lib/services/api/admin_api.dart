import 'package:fitman_common/fitman_common.dart';
import 'base_api.dart';

/// Service class for administrator-specific APIs.
class AdminApiService extends BaseApiService {
  AdminApiService({super.client});

  Future<List<AnthropometryMeasurement>> getAnthropometryMeasurementsForClient(
      String clientId) async {
    final data = await get('/api/admin/clients/$clientId/anthropometry') as List;
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

  Future<String> getSomatotypeProfileForClient(String clientId) async {
    final data =
        await get('/api/admin/clients/$clientId/anthropometry/somatotype');
    return data['profile_string'] as String? ?? 'Не удалось рассчитать соматотип.';
  }

  Future<WhtrProfiles> getWhtrProfilesForClient(String clientId) async {
    final data =
        await get('/api/admin/clients/$clientId/anthropometry/whtr-profiles');
    return WhtrProfiles.fromJson(data);
  }
}
