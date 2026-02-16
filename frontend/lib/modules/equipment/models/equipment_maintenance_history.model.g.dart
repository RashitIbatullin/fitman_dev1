// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'equipment_maintenance_history.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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
  equipmentItemId: json['equipment_item_id'] as String,
  dateSent: DateTime.parse(json['date_sent'] as String),
  dateReturned: json['date_returned'] == null
      ? null
      : DateTime.parse(json['date_returned'] as String),
  descriptionOfWork: json['description_of_work'] as String,
  cost: (json['cost'] as num?)?.toDouble(),
  performedBy: json['performed_by'] as String?,
  photos: (json['photos'] as List<dynamic>?)
      ?.map((e) => MaintenancePhoto.fromJson(e as Map<String, dynamic>))
      .toList(),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  createdBy: json['created_by'] as String?,
  updatedBy: json['updated_by'] as String?,
  archivedAt: json['archived_at'] == null
      ? null
      : DateTime.parse(json['archived_at'] as String),
  archivedBy: json['archived_by'] as String?,
  archivedReason: json['archived_reason'] as String?,
  note: json['note'] as String?,
);

Map<String, dynamic> _$$EquipmentMaintenanceHistoryImplToJson(
  _$EquipmentMaintenanceHistoryImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'equipment_item_id': instance.equipmentItemId,
  'date_sent': instance.dateSent.toIso8601String(),
  'date_returned': instance.dateReturned?.toIso8601String(),
  'description_of_work': instance.descriptionOfWork,
  'cost': instance.cost,
  'performed_by': instance.performedBy,
  'photos': instance.photos,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
  'created_by': instance.createdBy,
  'updated_by': instance.updatedBy,
  'archived_at': instance.archivedAt?.toIso8601String(),
  'archived_by': instance.archivedBy,
  'archived_reason': instance.archivedReason,
  'note': instance.note,
};
