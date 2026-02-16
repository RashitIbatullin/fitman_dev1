import 'package:http/http.dart' as http;

import '../../models/whtr_profiles.dart';
import '../../modules/users/models/user.dart';
import 'base_api.dart';

/// Service class for client-specific APIs.
class ClientApiService extends BaseApiService {
  ClientApiService({super.client});

  Future<Map<String, dynamic>> getClientDashboardData() async {
    return await get('/api/dashboard/client');
  }

  Future<User> getTrainerForClient() async {
    final data = await get('/api/client/trainer');
    return User.fromJson(data['trainer']);
  }

  Future<User> getInstructorForClient() async {
    final data = await get('/api/client/instructor');
    return User.fromJson(data['instructor']);
  }

  Future<User> getManagerForClient() async {
    final data = await get('/api/client/manager');
    return User.fromJson(data['manager']);
  }

  Future<Map<String, dynamic>> getOwnAnthropometryData() async {
    return await get('/api/client/anthropometry');
  }

  Future<String> getSomatotypeProfile() async {
    final data = await get('/api/client/anthropometry/somatotype');
    return data['profile_string'] as String? ?? 'Не удалось рассчитать соматотип.';
  }

  Future<WhtrProfiles> getWhtrProfiles() async {
    final data = await get('/api/client/anthropometry/whtr-profiles');
    return WhtrProfiles.fromJson(data);
  }

  Future<void> updateAnthropometryFixed({
    required int height,
    required int wristCirc,
    required int ankleCirc,
  }) async {
    await post('/api/client/anthropometry/fixed', body: {
      'height': height,
      'wristCirc': wristCirc,
      'ankleCirc': ankleCirc,
    });
  }

  Future<void> updateAnthropometryMeasurements({
    required String type,
    required double weight,
    required int shouldersCirc,
    required int breastCirc,
    required int waistCirc,
    required int hipsCirc,
  }) async {
    await post('/api/client/anthropometry/measurements', body: {
      'type': type,
      'weight': weight,
      'shouldersCirc': shouldersCirc,
      'breastCirc': breastCirc,
      'waistCirc': waistCirc,
      'hipsCirc': hipsCirc,
    });
  }

  Future<Map<String, dynamic>> uploadAnthropometryPhoto({
    required List<int> photoBytes,
    required String fileName,
    required String type,
    DateTime? photoDateTime,
  }) async {
    final file = http.MultipartFile.fromBytes('photo', photoBytes, filename: fileName);
    final fields = {'type': type};
    if (photoDateTime != null) {
      fields['photoDateTime'] = photoDateTime.toIso8601String();
    }
    
    return await multipartPost(
      '/api/client/anthropometry/photo',
      fields: fields,
      file: file,
    );
  }

  Future<User> updateClientProfile(Map<String, dynamic> profileData) async {
    final data = await put('/api/client/profile', body: profileData);
    return User.fromJson(data);
  }

  Future<Map<String, dynamic>> getCalorieTrackingData() async {
    return await get('/api/client/calorie-tracking');
  }

  Future<Map<String, dynamic>> getClientPreferences() async {
    return await get('/api/client/preferences');
  }

  Future<void> saveClientPreferences(Map<String, dynamic> preferences) async {
    await post('/api/client/preferences', body: preferences);
  }

  Future<Map<String, dynamic>> getProgressData() async {
    return await get('/api/client/progress');
  }
}