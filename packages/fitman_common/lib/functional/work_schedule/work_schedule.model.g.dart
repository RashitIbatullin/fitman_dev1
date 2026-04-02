// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work_schedule.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WorkScheduleImpl _$$WorkScheduleImplFromJson(Map<String, dynamic> json) =>
    _$WorkScheduleImpl(
      id: json['id'] as String,
      dayOfWeek: (json['day_of_week'] as num).toInt(),
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      isDayOff: json['is_day_off'] as bool,
    );

Map<String, dynamic> _$$WorkScheduleImplToJson(_$WorkScheduleImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'day_of_week': instance.dayOfWeek,
      'start_time': instance.startTime,
      'end_time': instance.endTime,
      'is_day_off': instance.isDayOff,
    };
