// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_schedule.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GroupSchedule _$GroupScheduleFromJson(Map<String, dynamic> json) =>
    GroupSchedule(
      id: json['id'] as String?,
      groupId: json['group_id'] as String,
      dayOfWeek: (json['day_of_week'] as num).toInt(),
      startTime: TimeOfDayCustom.fromJson(json['start_time'] as String),
      endTime: TimeOfDayCustom.fromJson(json['end_time'] as String),
      isActive: json['is_active'] as bool? ?? true,
    );

Map<String, dynamic> _$GroupScheduleToJson(GroupSchedule instance) =>
    <String, dynamic>{
      'id': instance.id,
      'group_id': instance.groupId,
      'day_of_week': instance.dayOfWeek,
      'start_time': instance.startTime,
      'end_time': instance.endTime,
      'is_active': instance.isActive,
    };
