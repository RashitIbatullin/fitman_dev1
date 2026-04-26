import 'package:fitman_backend/modules/rooms/repositories/room_schedule_repository.dart';
import 'package:fitman_common/modules/rooms/room_schedule.model.dart';

class RoomScheduleService {
  const RoomScheduleService(this._roomScheduleRepository);

  final RoomScheduleRepository _roomScheduleRepository;

  Future<List<RoomSchedule>> getSchedulesByRoomId(String roomId) {
    return _roomScheduleRepository.getSchedulesByRoomId(roomId);
  }

  Future<void> updateSchedules(String roomId, List<RoomSchedule> schedules, {String? updatedBy}) async {
    // Here you can add business logic validation before updating
    // For example, ensure open_time is before close_time, etc.

    // Assign updatedBy to each schedule item if provided
    final schedulesWithUpdater = schedules.map((s) => s.copyWith(updatedBy: updatedBy)).toList();
    
    await _roomScheduleRepository.updateSchedules(roomId, schedulesWithUpdater);
  }
}
