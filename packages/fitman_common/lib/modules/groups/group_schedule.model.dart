import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:fitman_common/custom/time_of_day_custom.dart';

part 'group_schedule.model.g.dart';

@JsonSerializable()
class GroupSchedule extends Equatable {
  final String? id;
  final String groupId;
  final int dayOfWeek; // 1-7 (понедельник-воскресенье)
  final TimeOfDayCustom startTime;
  final TimeOfDayCustom endTime;
  final bool isActive;

  const GroupSchedule({
    this.id,
    required this.groupId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.isActive = true,
  });

  factory GroupSchedule.fromJson(Map<String, dynamic> json) =>
      _$GroupScheduleFromJson(json);
  Map<String, dynamic> toJson() => _$GroupScheduleToJson(this);

  @override
  List<Object?> get props => [
        id,
        groupId,
        dayOfWeek,
        startTime,
        endTime,
        isActive,
      ];
}

