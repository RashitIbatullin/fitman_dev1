import 'package:http/http.dart' as http;
import 'package:fitman_common/fitman_common.dart';
import 'base_api.dart';

/// Service class for administrator-specific APIs.
class AdminApiService extends BaseApiService {
  AdminApiService({super.client});

  Future<Map<String, dynamic>> getAnthropometryDataForClient(String clientId) async {
    return await get('/api/admin/clients/$clientId/anthropometry');
  }

  Future<String> getSomatotypeProfileForClient(String clientId) async {
    final data = await get('/api/admin/clients/$clientId/anthropometry/somatotype');
    return data['profile_string'] as String? ?? 'Не удалось рассчитать соматотип.';
  }

  Future<WhtrProfiles> getWhtrProfilesForClient(String clientId) async {
    final data = await get('/api/admin/clients/$clientId/anthropometry/whtr-profiles');
    return WhtrProfiles.fromJson(data);
  }

  Future<void> updateAnthropometryFixedForClient({
    required String clientId,
    required int height,
    required int wristCirc,
    required int ankleCirc,
  }) async {
    await post('/api/admin/clients/$clientId/anthropometry/fixed', body: {
      'height': height,
      'wristCirc': wristCirc,
      'ankleCirc': ankleCirc,
    });
  }

  Future<void> updateAnthropometryMeasurementsForClient({
    required String clientId,
    required String type,
    required double weight,
    required int shouldersCirc,
    required int breastCirc,
    required int waistCirc,
    required int hipsCirc,
  }) async {
    await post('/api/admin/clients/$clientId/anthropometry/measurements', body: {
      'type': type,
      'weight': weight,
      'shouldersCirc': shouldersCirc,
      'breastCirc': breastCirc,
      'waistCirc': waistCirc,
      'hipsCirc': hipsCirc,
    });
  }

  Future<Map<String, dynamic>> uploadAnthropometryPhotoForClient({
    required String clientId,
    required List<int> photoBytes,
    required String fileName,
    required String type,
    DateTime? photoDateTime,
  }) async {
    final file = http.MultipartFile.fromBytes('photo', photoBytes, filename: fileName);
    final fields = {
      'type': type,
      'clientId': clientId,
    };
    if (photoDateTime != null) {
      fields['photoDateTime'] = photoDateTime.toIso8601String();
    }
    
    return await multipartPost(
      '/api/admin/clients/$clientId/anthropometry/photo',
      fields: fields,
      file: file,
    );
  }
}
