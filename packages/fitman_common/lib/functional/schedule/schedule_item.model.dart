import 'package:freezed_annotation/freezed_annotation.dart';

part 'schedule_item.model.freezed.dart';
part 'schedule_item.model.g.dart';

@freezed
class ScheduleItem with _$ScheduleItem {
  const factory ScheduleItem({
    required String id,
    required String trainingPlanName,
    required DateTime startTime,
    required DateTime endTime,
    required String status,
    required String trainerName,
  }) = _ScheduleItem;

  factory ScheduleItem.fromJson(Map<String, dynamic> json) =>
      _$ScheduleItemFromJson(json);
}
