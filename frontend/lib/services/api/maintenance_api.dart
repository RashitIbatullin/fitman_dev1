import 'package:http/http.dart' as http;
import '../../modules/maintenance/models/equipment_maintenance_history.model.dart';
import 'base_api.dart';

/// Service class for maintenance-related APIs.
class MaintenanceApiService extends BaseApiService {
  MaintenanceApiService({super.client});

  Future<List<EquipmentMaintenanceHistory>> getAllMaintenanceHistory() async {
    final data = await get('/api/maintenance');
    return (data as List).map((json) => EquipmentMaintenanceHistory.fromJson(json)).toList();
  }

  Future<List<EquipmentMaintenanceHistory>> getMaintenanceHistory(String itemId) async {
    final data = await get('/api/maintenance/item/$itemId');
    return (data as List).map((json) => EquipmentMaintenanceHistory.fromJson(json)).toList();
  }

  Future<EquipmentMaintenanceHistory> createMaintenanceHistory(EquipmentMaintenanceHistory history) async {
    final data = await post('/api/maintenance', body: history.toJson());
    return EquipmentMaintenanceHistory.fromJson(data);
  }

  Future<EquipmentMaintenanceHistory> updateMaintenanceHistory(String historyId, EquipmentMaintenanceHistory history) async {
    final data = await put('/api/maintenance/$historyId', body: history.toJson());
    return EquipmentMaintenanceHistory.fromJson(data);
  }

  Future<void> archiveMaintenanceHistory(String historyId, String reason) async {
    // The backend expects the reason in the body for a DELETE request.
    await delete('/api/maintenance/$historyId', body: {'reason': reason});
  }

  Future<String> uploadMaintenancePhoto({
    required String maintenanceId,
    required List<int> photoBytes,
    required String fileName,
    String? comment,
    required String timing,
  }) async {
    final file = http.MultipartFile.fromBytes('photo', photoBytes, filename: fileName);
    final response = await multipartPost(
      '/api/maintenance/$maintenanceId/photos',
      fields: {
        'comment': comment ?? '',
        'timing': timing,
      },
      file: file,
    );
    return response['url'] as String;
  }
}
