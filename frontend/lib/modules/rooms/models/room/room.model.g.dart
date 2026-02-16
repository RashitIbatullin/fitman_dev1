// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RoomImpl _$$RoomImplFromJson(Map<String, dynamic> json) => _$RoomImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  roomNumber: json['room_number'] as String?,
  type: const RoomTypeConverter().fromJson((json['type'] as num).toInt()),
  floor: (json['floor'] as num?)?.toInt(),
  buildingId: json['building_id'] as String?,
  buildingName: json['building_name'] as String?,
  maxCapacity: (json['max_capacity'] as num?)?.toInt() ?? 30,
  area: (json['area'] as num?)?.toDouble(),
  openTime: const TimeOfDayConverter().fromJson(json['open_time'] as String?),
  closeTime: const TimeOfDayConverter().fromJson(json['close_time'] as String?),
  workingDays:
      (json['working_days'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const [],
  isActive: json['is_active'] as bool? ?? true,
  deactivateReason: json['deactivate_reason'] as String?,
  deactivateAt: json['deactivate_at'] == null
      ? null
      : DateTime.parse(json['deactivate_at'] as String),
  deactivateBy: json['deactivate_by'] as String?,
  photoUrls:
      (json['photo_urls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  floorPlanUrl: json['floor_plan_url'] as String?,
  note: json['note'] as String?,
  archivedAt: json['archived_at'] == null
      ? null
      : DateTime.parse(json['archived_at'] as String),
  archivedReason: json['archived_reason'] as String?,
  archivedBy: json['archived_by'] as String?,
  archivedByName: json['archived_by_name'] as String?,
);

Map<String, dynamic> _$$RoomImplToJson(_$RoomImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'room_number': instance.roomNumber,
      'type': const RoomTypeConverter().toJson(instance.type),
      'floor': instance.floor,
      'building_id': instance.buildingId,
      'building_name': instance.buildingName,
      'max_capacity': instance.maxCapacity,
      'area': instance.area,
      'open_time': const TimeOfDayConverter().toJson(instance.openTime),
      'close_time': const TimeOfDayConverter().toJson(instance.closeTime),
      'working_days': instance.workingDays,
      'is_active': instance.isActive,
      'deactivate_reason': instance.deactivateReason,
      'deactivate_at': instance.deactivateAt?.toIso8601String(),
      'deactivate_by': instance.deactivateBy,
      'photo_urls': instance.photoUrls,
      'floor_plan_url': instance.floorPlanUrl,
      'note': instance.note,
      'archived_at': instance.archivedAt?.toIso8601String(),
      'archived_reason': instance.archivedReason,
      'archived_by': instance.archivedBy,
      'archived_by_name': instance.archivedByName,
    };
