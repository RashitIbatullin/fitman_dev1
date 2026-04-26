// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_schedule.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RoomScheduleImpl _$$RoomScheduleImplFromJson(Map<String, dynamic> json) =>
    _$RoomScheduleImpl(
      id: json['id'] as String,
      roomId: json['room_id'] as String,
      dayOfWeek: (json['day_of_week'] as num).toInt(),
      isWorkingDay: json['is_working_day'] as bool? ?? true,
      openTime: json['open_time'] == null
          ? null
          : TimeOfDayCustom.fromJson(json['open_time'] as String),
      closeTime: json['close_time'] == null
          ? null
          : TimeOfDayCustom.fromJson(json['close_time'] as String),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      createdBy: json['created_by'] as String?,
      updatedBy: json['updated_by'] as String?,
    );

Map<String, dynamic> _$$RoomScheduleImplToJson(_$RoomScheduleImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'room_id': instance.roomId,
      'day_of_week': instance.dayOfWeek,
      'is_working_day': instance.isWorkingDay,
      'open_time': instance.openTime,
      'close_time': instance.closeTime,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'created_by': instance.createdBy,
      'updated_by': instance.updatedBy,
    };
