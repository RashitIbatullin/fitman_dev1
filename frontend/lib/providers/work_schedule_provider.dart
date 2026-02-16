import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/work_schedule.dart';
import '../../services/api_service.dart';

final workScheduleProvider =
    StateNotifierProvider<WorkScheduleNotifier, AsyncValue<List<WorkSchedule>>>(
      (ref) {
        return WorkScheduleNotifier();
      },
    );

class WorkScheduleNotifier
    extends StateNotifier<AsyncValue<List<WorkSchedule>>> {
  WorkScheduleNotifier() : super(const AsyncValue.loading()) {
    _fetchWorkSchedules();
  }

  Future<void> _fetchWorkSchedules() async {
    try {
      final schedulesJson = await ApiService.getWorkSchedules();
      final schedules = schedulesJson
          .map((json) => WorkSchedule.fromJson(json as Map<String, dynamic>))
          .toList();
      state = AsyncValue.data(schedules);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateWorkSchedule(WorkSchedule schedule) async {
    try {
      await ApiService.updateWorkSchedule(schedule.toJson());
      _fetchWorkSchedules();
    } catch (e) {
      // Handle error
    }
  }
}
