import '../../models/schedule_item.dart';
import 'base_api.dart';

/// Service class for schedule-related APIs.
class ScheduleApiService extends BaseApiService {
  ScheduleApiService({super.client});

  /// Fetches the main schedule.
  Future<List<ScheduleItem>> getSchedule() async {
    final data = await get('/api/schedule');
    final scheduleList = data['schedule'] as List;
    return scheduleList.map((item) => ScheduleItem.fromJson(item)).toList();
  }

  /// Fetches work schedules.
  Future<List<dynamic>> getWorkSchedules() async {
    return await get('/api/work-schedules');
  }

  /// Updates a work schedule.
  Future<void> updateWorkSchedule(Map<String, dynamic> schedule) async {
    await post('/api/work-schedules', body: schedule);
  }
}