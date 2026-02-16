import 'package:freezed_annotation/freezed_annotation.dart';

part 'work_schedule.model.freezed.dart';
part 'work_schedule.model.g.dart';

@freezed
class WorkSchedule with _$WorkSchedule {
  const factory WorkSchedule({
    required String id,
    required String staffId,
    required int dayOfWeek,
    required String startTime,
    required String endTime,
  }) = _WorkSchedule;

  factory WorkSchedule.fromJson(Map<String, dynamic> json) =>
      _$WorkScheduleFromJson(json);
}
