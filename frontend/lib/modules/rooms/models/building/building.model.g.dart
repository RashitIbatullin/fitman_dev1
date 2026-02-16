// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'building.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BuildingImpl _$$BuildingImplFromJson(Map<String, dynamic> json) =>
    _$BuildingImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      note: json['note'] as String?,
      createdAt: const NullableDateTimeConverter().fromJson(
        json['created_at'] as String?,
      ),
      updatedAt: const NullableDateTimeConverter().fromJson(
        json['updated_at'] as String?,
      ),
      createdBy: json['created_by'] as String?,
      updatedBy: json['updated_by'] as String?,
      archivedAt: const NullableDateTimeConverter().fromJson(
        json['archived_at'] as String?,
      ),
      archivedBy: json['archived_by'] as String?,
      archivedByName: json['archived_by_name'] as String?,
      archivedReason: json['archived_reason'] as String?,
    );

Map<String, dynamic> _$$BuildingImplToJson(
  _$BuildingImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'address': instance.address,
  'note': instance.note,
  'created_at': const NullableDateTimeConverter().toJson(instance.createdAt),
  'updated_at': const NullableDateTimeConverter().toJson(instance.updatedAt),
  'created_by': instance.createdBy,
  'updated_by': instance.updatedBy,
  'archived_at': const NullableDateTimeConverter().toJson(instance.archivedAt),
  'archived_by': instance.archivedBy,
  'archived_by_name': instance.archivedByName,
  'archived_reason': instance.archivedReason,
};
