// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'equipment_maintenance_history.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MaintenancePhotoImpl _$$MaintenancePhotoImplFromJson(
  Map<String, dynamic> json,
) => _$MaintenancePhotoImpl(
  id: json['id'] as String,
  maintenanceId: json['maintenance_id'] as String,
  url: json['url'] as String,
  comment: json['comment'] as String?,
  timing: $enumDecode(_$PhotoTimingEnumMap, json['timing']),
  takenAt: json['taken_at'] == null
      ? null
      : DateTime.parse(json['taken_at'] as String),
  takenBy: json['taken_by'] as String?,
);

Map<String, dynamic> _$$MaintenancePhotoImplToJson(
  _$MaintenancePhotoImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'maintenance_id': instance.maintenanceId,
  'url': instance.url,
  'comment': instance.comment,
  'timing': _$PhotoTimingEnumMap[instance.timing]!,
  'taken_at': instance.takenAt?.toIso8601String(),
  'taken_by': instance.takenBy,
};

const _$PhotoTimingEnumMap = {
  PhotoTiming.before: 'before',
  PhotoTiming.after: 'after',
};

_$EquipmentMaintenanceHistoryImpl _$$EquipmentMaintenanceHistoryImplFromJson(
  Map<String, dynamic> json,
) => _$EquipmentMaintenanceHistoryImpl(
  id: json['id'] as String,
  equipmentItemId: json['equipment_item_id'] as String,
  equipmentName: json['equipment_name'] as String?,
  type: $enumDecode(_$MaintenanceTypeEnumMap, json['type']),
  status: $enumDecode(_$MaintenanceStatusEnumMap, json['status']),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  startedAt: json['started_at'] == null
      ? null
      : DateTime.parse(json['started_at'] as String),
  completedAt: json['completed_at'] == null
      ? null
      : DateTime.parse(json['completed_at'] as String),
  equipmentAvailableFrom: json['equipment_available_from'] == null
      ? null
      : DateTime.parse(json['equipment_available_from'] as String),
  reportedProblem: json['reported_problem'] as String,
  workDescription: json['work_description'] as String?,
  reportedBy: json['reported_by'] as String,
  assignedToUserId: json['assigned_to_user_id'] as String?,
  assignedToStaffId: json['assigned_to_staff_id'] as String?,
  relatedBookingId: json['related_booking_id'] as String?,
  causedDowntime: json['caused_downtime'] as bool? ?? false,
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  isArchived: json['is_archived'] as bool? ?? false,
  photos: (json['photos'] as List<dynamic>?)
      ?.map((e) => MaintenancePhoto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$$EquipmentMaintenanceHistoryImplToJson(
  _$EquipmentMaintenanceHistoryImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'equipment_item_id': instance.equipmentItemId,
  'equipment_name': instance.equipmentName,
  'type': _$MaintenanceTypeEnumMap[instance.type]!,
  'status': _$MaintenanceStatusEnumMap[instance.status]!,
  'created_at': instance.createdAt?.toIso8601String(),
  'started_at': instance.startedAt?.toIso8601String(),
  'completed_at': instance.completedAt?.toIso8601String(),
  'equipment_available_from': instance.equipmentAvailableFrom
      ?.toIso8601String(),
  'reported_problem': instance.reportedProblem,
  'work_description': instance.workDescription,
  'reported_by': instance.reportedBy,
  'assigned_to_user_id': instance.assignedToUserId,
  'assigned_to_staff_id': instance.assignedToStaffId,
  'related_booking_id': instance.relatedBookingId,
  'caused_downtime': instance.causedDowntime,
  'updated_at': instance.updatedAt?.toIso8601String(),
  'is_archived': instance.isArchived,
  'photos': instance.photos,
};

const _$MaintenanceTypeEnumMap = {
  MaintenanceType.preventive: 'preventive',
  MaintenanceType.corrective: 'corrective',
};

const _$MaintenanceStatusEnumMap = {
  MaintenanceStatus.reported: 'reported',
  MaintenanceStatus.inProgress: 'inProgress',
  MaintenanceStatus.completed: 'completed',
  MaintenanceStatus.cancelled: 'cancelled',
};
