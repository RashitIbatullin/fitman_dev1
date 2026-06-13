// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'equipment_booking.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EquipmentBookingImpl _$$EquipmentBookingImplFromJson(
  Map<String, dynamic> json,
) => _$EquipmentBookingImpl(
  id: json['id'] as String,
  equipmentItemId: json['equipment_item_id'] as String,
  bookedById: json['booked_by_id'] as String,
  startTime: DateTime.parse(json['start_time'] as String),
  endTime: DateTime.parse(json['end_time'] as String),
  lessonId: json['lesson_id'] as String?,
  trainingGroupId: json['training_group_id'] as String?,
  purpose: json['purpose'] as String,
  status: $enumDecode(_$BookingStatusEnumMap, json['status']),
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$$EquipmentBookingImplToJson(
  _$EquipmentBookingImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'equipment_item_id': instance.equipmentItemId,
  'booked_by_id': instance.bookedById,
  'start_time': instance.startTime.toIso8601String(),
  'end_time': instance.endTime.toIso8601String(),
  'lesson_id': instance.lessonId,
  'training_group_id': instance.trainingGroupId,
  'purpose': instance.purpose,
  'status': _$BookingStatusEnumMap[instance.status]!,
  'notes': instance.notes,
};

const _$BookingStatusEnumMap = {
  BookingStatus.confirmed: 'confirmed',
  BookingStatus.active: 'active',
  BookingStatus.completed: 'completed',
  BookingStatus.cancelled: 'cancelled',
};
