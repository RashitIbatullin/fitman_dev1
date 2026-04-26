// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fitman_common/custom/time_of_day_custom.dart';

part 'room_schedule.model.freezed.dart';
part 'room_schedule.model.g.dart';

@freezed
class RoomSchedule with _$RoomSchedule {
  const factory RoomSchedule({
    required String id,
    required String roomId,
    required int dayOfWeek,
    @Default(true) bool isWorkingDay,
    TimeOfDayCustom? openTime,
    TimeOfDayCustom? closeTime,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) = _RoomSchedule;

  factory RoomSchedule.fromJson(Map<String, dynamic> json) =>
      _$RoomScheduleFromJson(json);
}
