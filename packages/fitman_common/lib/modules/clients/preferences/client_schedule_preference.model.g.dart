// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_schedule_preference.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ClientSchedulePreferenceImpl _$$ClientSchedulePreferenceImplFromJson(
  Map<String, dynamic> json,
) => _$ClientSchedulePreferenceImpl(
  id: (json['id'] as num?)?.toInt(),
  clientId: (json['client_id'] as num).toInt(),
  dayOfWeek: (json['day_of_week'] as num).toInt(),
  preferredStartTime: json['preferred_start_time'] as String,
  preferredEndTime: json['preferred_end_time'] as String,
);

Map<String, dynamic> _$$ClientSchedulePreferenceImplToJson(
  _$ClientSchedulePreferenceImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'client_id': instance.clientId,
  'day_of_week': instance.dayOfWeek,
  'preferred_start_time': instance.preferredStartTime,
  'preferred_end_time': instance.preferredEndTime,
};
