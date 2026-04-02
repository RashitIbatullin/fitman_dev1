// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_item.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ScheduleItemImpl _$$ScheduleItemImplFromJson(Map<String, dynamic> json) =>
    _$ScheduleItemImpl(
      id: json['id'] as String,
      trainingPlanName: json['training_plan_name'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      status: json['status'] as String,
      trainerName: json['trainer_name'] as String,
    );

Map<String, dynamic> _$$ScheduleItemImplToJson(_$ScheduleItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'training_plan_name': instance.trainingPlanName,
      'start_time': instance.startTime.toIso8601String(),
      'end_time': instance.endTime.toIso8601String(),
      'status': instance.status,
      'trainer_name': instance.trainerName,
    };
