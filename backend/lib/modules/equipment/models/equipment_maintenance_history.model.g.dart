// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'equipment_maintenance_history.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MaintenancePhoto _$MaintenancePhotoFromJson(Map<String, dynamic> json) =>
    MaintenancePhoto(url: json['url'] as String, note: json['note'] as String);

EquipmentMaintenanceHistory _$EquipmentMaintenanceHistoryFromJson(
  Map<String, dynamic> json,
) => EquipmentMaintenanceHistory(
  id: json['id'] as String,
  equipmentItemId: json['equipmentItemId'] as String,
  dateSent: DateTime.parse(json['dateSent'] as String),
  dateReturned: json['dateReturned'] == null
      ? null
      : DateTime.parse(json['dateReturned'] as String),
  descriptionOfWork: json['descriptionOfWork'] as String,
  cost: (json['cost'] as num?)?.toDouble(),
  performedBy: json['performedBy'] as String?,
  photos: (json['photos'] as List<dynamic>?)
      ?.map((e) => MaintenancePhoto.fromJson(e as Map<String, dynamic>))
      .toList(),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  createdBy: json['createdBy'] as String?,
  updatedBy: json['updatedBy'] as String?,
  archivedAt: json['archivedAt'] == null
      ? null
      : DateTime.parse(json['archivedAt'] as String),
  archivedBy: json['archivedBy'] as String?,
  archivedReason: json['archivedReason'] as String?,
  note: json['note'] as String?,
);


_$MaintenancePhotoImpl _$$MaintenancePhotoImplFromJson(
  Map<String, dynamic> json,
) => _$MaintenancePhotoImpl(
  url: json['url'] as String,
  note: json['note'] as String,
);

Map<String, dynamic> _$$MaintenancePhotoImplToJson(
  _$MaintenancePhotoImpl instance,
) => <String, dynamic>{'url': instance.url, 'note': instance.note};

_$EquipmentMaintenanceHistoryImpl _$$EquipmentMaintenanceHistoryImplFromJson(
  Map<String, dynamic> json,
) => _$EquipmentMaintenanceHistoryImpl(
  id: json['id'] as String,
  equipmentItemId: json['equipmentItemId'] as String,
  dateSent: DateTime.parse(json['dateSent'] as String),
  dateReturned: json['dateReturned'] == null
      ? null
      : DateTime.parse(json['dateReturned'] as String),
  descriptionOfWork: json['descriptionOfWork'] as String,
  cost: (json['cost'] as num?)?.toDouble(),
  performedBy: json['performedBy'] as String?,
  photos: (json['photos'] as List<dynamic>?)
      ?.map((e) => MaintenancePhoto.fromJson(e as Map<String, dynamic>))
      .toList(),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  createdBy: json['createdBy'] as String?,
  updatedBy: json['updatedBy'] as String?,
  archivedAt: json['archivedAt'] == null
      ? null
      : DateTime.parse(json['archivedAt'] as String),
  archivedBy: json['archivedBy'] as String?,
  archivedReason: json['archivedReason'] as String?,
  note: json['note'] as String?,
);

Map<String, dynamic> _$$EquipmentMaintenanceHistoryImplToJson(
  _$EquipmentMaintenanceHistoryImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'equipmentItemId': instance.equipmentItemId,
  'dateSent': instance.dateSent.toIso8601String(),
  'dateReturned': instance.dateReturned?.toIso8601String(),
  'descriptionOfWork': instance.descriptionOfWork,
  'cost': instance.cost,
  'performedBy': instance.performedBy,
  'photos': instance.photos,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'createdBy': instance.createdBy,
  'updatedBy': instance.updatedBy,
  'archivedAt': instance.archivedAt?.toIso8601String(),
  'archivedBy': instance.archivedBy,
  'archivedReason': instance.archivedReason,
  'note': instance.note,
};
