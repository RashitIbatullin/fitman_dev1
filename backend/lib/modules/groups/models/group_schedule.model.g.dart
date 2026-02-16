// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_schedule.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GroupSchedule _$GroupScheduleFromJson(Map<String, dynamic> json) =>
    GroupSchedule(
      id: (json['id'] as num).toInt(),
      groupId: (json['groupId'] as num).toInt(),
      dayOfWeek: (json['dayOfWeek'] as num).toInt(),
      startTime: _timeOfDayFromJson(json['startTime'] as String),
      endTime: _timeOfDayFromJson(json['endTime'] as String),
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$GroupScheduleToJson(GroupSchedule instance) =>
    <String, dynamic>{
      'id': instance.id,
      'groupId': instance.groupId,
      'dayOfWeek': instance.dayOfWeek,
      'startTime': _timeOfDayToJson(instance.startTime),
      'endTime': _timeOfDayToJson(instance.endTime),
      'isActive': instance.isActive,
    };
