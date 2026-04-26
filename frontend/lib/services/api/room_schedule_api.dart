import 'package:fitman_common/modules/rooms/room_schedule.model.dart';
import 'package:fitman_app/services/api/base_api.dart';

class RoomScheduleApiService extends BaseApiService {
  Future<List<RoomSchedule>> getRoomSchedules(String roomId) async {
    final response = await get('/api/rooms/$roomId/schedules');
    return (response as List).map((json) => RoomSchedule.fromJson(json)).toList();
  }

  Future<void> updateRoomSchedules(String roomId, List<RoomSchedule> schedules) async {
    final body = schedules.map((s) => s.toJson()).toList();
    await putList('/api/rooms/$roomId/schedules', body: body); // Send directly the list of JSONs
  }
}
