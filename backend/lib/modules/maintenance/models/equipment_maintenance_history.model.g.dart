// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'equipment_maintenance_history.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MaintenancePhotoImpl _$$MaintenancePhotoImplFromJson(
  Map<String, dynamic> json,
) => _$MaintenancePhotoImpl(
  id: json['id'] as String,
  maintenanceId: json['maintenanceId'] as String,
  url: json['url'] as String,
  comment: json['comment'] as String?,
  timing: $enumDecode(_$PhotoTimingEnumMap, json['timing']),
  takenAt: json['takenAt'] == null
      ? null
      : DateTime.parse(json['takenAt'] as String),
  takenBy: json['takenBy'] as String?,
);

Map<String, dynamic> _$$MaintenancePhotoImplToJson(
  _$MaintenancePhotoImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'maintenanceId': instance.maintenanceId,
  'url': instance.url,
  'comment': instance.comment,
  'timing': _$PhotoTimingEnumMap[instance.timing]!,
  'takenAt': instance.takenAt?.toIso8601String(),
  'takenBy': instance.takenBy,
};

const _$PhotoTimingEnumMap = {
  PhotoTiming.before: 'before',
  PhotoTiming.after: 'after',
};

_$EquipmentMaintenanceHistoryImpl _$$EquipmentMaintenanceHistoryImplFromJson(
  Map<String, dynamic> json,
) => _$EquipmentMaintenanceHistoryImpl(
  id: json['id'] as String,
  equipmentItemId: json['equipmentItemId'] as String,
  equipmentName: json['equipmentName'] as String?,
  type: $enumDecode(_$MaintenanceTypeEnumMap, json['type']),
  status: $enumDecode(_$MaintenanceStatusEnumMap, json['status']),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  startedAt: json['startedAt'] == null
      ? null
      : DateTime.parse(json['startedAt'] as String),
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
  equipmentAvailableFrom: json['equipmentAvailableFrom'] == null
      ? null
      : DateTime.parse(json['equipmentAvailableFrom'] as String),
  reportedProblem: json['reportedProblem'] as String,
  workDescription: json['workDescription'] as String?,
  reportedBy: json['reportedBy'] as String,
  assignedToUserId: json['assignedToUserId'] as String?,
  assignedToStaffId: json['assignedToStaffId'] as String?,
  relatedBookingId: json['relatedBookingId'] as String?,
  causedDowntime: json['causedDowntime'] as bool? ?? false,
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  archivedAt: json['archivedAt'] == null
      ? null
      : DateTime.parse(json['archivedAt'] as String),
  archivedBy: json['archivedBy'] as String?,
  archivedReason: json['archivedReason'] as String?,
  photos: (json['photos'] as List<dynamic>?)
      ?.map((e) => MaintenancePhoto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$$EquipmentMaintenanceHistoryImplToJson(
  _$EquipmentMaintenanceHistoryImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'equipmentItemId': instance.equipmentItemId,
  'equipmentName': instance.equipmentName,
  'type': _$MaintenanceTypeEnumMap[instance.type]!,
  'status': _$MaintenanceStatusEnumMap[instance.status]!,
  'createdAt': instance.createdAt?.toIso8601String(),
  'startedAt': instance.startedAt?.toIso8601String(),
  'completedAt': instance.completedAt?.toIso8601String(),
  'equipmentAvailableFrom': instance.equipmentAvailableFrom?.toIso8601String(),
  'reportedProblem': instance.reportedProblem,
  'workDescription': instance.workDescription,
  'reportedBy': instance.reportedBy,
  'assignedToUserId': instance.assignedToUserId,
  'assignedToStaffId': instance.assignedToStaffId,
  'relatedBookingId': instance.relatedBookingId,
  'causedDowntime': instance.causedDowntime,
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'archivedAt': instance.archivedAt?.toIso8601String(),
  'archivedBy': instance.archivedBy,
  'archivedReason': instance.archivedReason,
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
