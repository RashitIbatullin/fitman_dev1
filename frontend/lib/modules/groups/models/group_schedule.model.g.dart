// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_schedule.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GroupSchedule _$GroupScheduleFromJson(Map<String, dynamic> json) =>
    GroupSchedule(
      id: (json['id'] as num?)?.toInt(),
      groupId: (json['group_id'] as num).toInt(),
      dayOfWeek: (json['day_of_week'] as num).toInt(),
      startTime: _timeOfDayFromJson(json['start_time'] as String),
      endTime: _timeOfDayFromJson(json['end_time'] as String),
      isActive: json['is_active'] as bool? ?? true,
    );

Map<String, dynamic> _$GroupScheduleToJson(GroupSchedule instance) =>
    <String, dynamic>{
      'id': instance.id,
      'group_id': instance.groupId,
      'day_of_week': instance.dayOfWeek,
      'start_time': _timeOfDayToJson(instance.startTime),
      'end_time': _timeOfDayToJson(instance.endTime),
      'is_active': instance.isActive,
    };
