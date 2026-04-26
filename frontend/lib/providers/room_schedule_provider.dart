import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitman_common/modules/rooms/room_schedule.model.dart';
import 'package:fitman_app/services/api_service.dart';

// A StateNotifier to manage the list of RoomSchedule objects for a given room.
class RoomScheduleNotifier extends StateNotifier<AsyncValue<List<RoomSchedule>>> {
  final String roomId;

  RoomScheduleNotifier(this.roomId) : super(const AsyncValue.loading()) {
    _fetchRoomSchedules();
  }

  Future<void> _fetchRoomSchedules() async {
    try {
      final schedules = await ApiService.getRoomSchedules(roomId);
      state = AsyncValue.data(schedules);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateRoomSchedules(List<RoomSchedule> updatedSchedules) async {
    state = const AsyncValue.loading();
    try {
      await ApiService.updateRoomSchedules(roomId, updatedSchedules);
      state = AsyncValue.data(updatedSchedules); // Optimistically update UI
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

// Provider that takes a roomId and returns a RoomScheduleNotifier
final roomScheduleProvider = StateNotifierProvider.family<
    RoomScheduleNotifier, AsyncValue<List<RoomSchedule>>, String>((ref, roomId) {
  return RoomScheduleNotifier(roomId); // ApiService is a static facade
});
