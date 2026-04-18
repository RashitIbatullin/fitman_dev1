import 'package:http/http.dart' as http;

import 'package:fitman_common/fitman_common.dart';
import 'base_api.dart';

/// Service class for client-specific APIs.
class ClientApiService extends BaseApiService {
  ClientApiService({super.client});

  Future<Map<String, dynamic>> getClientDashboardData() async {
    return await get('/api/dashboard/client');
  }

  Future<User?> getTrainerForClient() async {
    final data = await getAllow404('/api/client/trainer');
    if (data == null) return null;
    return User.fromJson(data['trainer']);
  }

  Future<User?> getInstructorForClient() async {
    final data = await getAllow404('/api/client/instructor');
    if (data == null) return null;
    return User.fromJson(data['instructor']);
  }

  Future<User?> getManagerForClient() async {
    final data = await getAllow404('/api/client/manager');
    if (data == null) return null;
    return User.fromJson(data['manager']);
  }

  Future<List<AnthropometryMeasurement>> getAnthropometryMeasurements(
      {bool? includeArchived}) async {
    var endpoint = '/api/client/anthropometry';
    if (includeArchived != null) {
      endpoint += '?includeArchived=$includeArchived';
    }
    final data = await get(endpoint) as List;
    return data.map((item) => AnthropometryMeasurement.fromJson(item)).toList();
  }

  Future<AnthropometryMeasurement> saveAnthropometryMeasurement(
    AnthropometryMeasurement measurement,
  ) async {
    final data = await post('/api/client/anthropometry', body: measurement.toJson());
    return AnthropometryMeasurement.fromJson(data);
  }

  Future<AnthropometryFixed?> getFixedAnthropometry() async {
    final data = await getAllow404('/api/client/anthropometry/fixed');
    if (data == null) return null;
    return AnthropometryFixed.fromJson(data);
  }

  Future<AnthropometryFixed> saveFixedAnthropometry(
    AnthropometryFixed fixedData,
  ) async {
    final data = await post('/api/client/anthropometry/fixed', body: fixedData.toJson());
    return AnthropometryFixed.fromJson(data);
  }

  Future<Map<String, dynamic>> getSomatotypeProfile() async {
    final data = await get('/api/client/anthropometry/somatotype');
    return data;
  }

  Future<WhtrProfiles> getWhtrProfiles() async {
    final data = await get('/api/client/anthropometry/whtr-profiles');
    return WhtrProfiles.fromJson(data);
  }

  Future<Map<String, dynamic>> uploadAnthropometryPhoto({
    required List<int> photoBytes,
    required String fileName,
  }) async {
    final file = http.MultipartFile.fromBytes('photo', photoBytes, filename: fileName);
    return await multipartPost(
      '/api/client/anthropometry/photo',
      fields: {},
      file: file,
    );
  }

  Future<User> updateClientProfile(Map<String, dynamic> profileData) async {
    final data = await put('/api/client/profile', body: profileData);
    return User.fromJson(data);
  }

  Future<List<dynamic>> getCalorieTrackingData() async {
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