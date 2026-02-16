// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work_schedule.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WorkScheduleImpl _$$WorkScheduleImplFromJson(Map<String, dynamic> json) =>
    _$WorkScheduleImpl(
      id: json['id'] as String,
      staffId: json['staff_id'] as String,
      dayOfWeek: (json['day_of_week'] as num).toInt(),
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
    );

Map<String, dynamic> _$$WorkScheduleImplToJson(_$WorkScheduleImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'staff_id': instance.staffId,
      'day_of_week': instance.dayOfWeek,
      'start_time': instance.startTime,
      'end_time': instance.endTime,
    };
