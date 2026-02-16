// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'equipment_type.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EquipmentTypeImpl _$$EquipmentTypeImplFromJson(Map<String, dynamic> json) =>
    _$EquipmentTypeImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      category: const EquipmentCategoryConverter().fromJson(
        (json['category'] as num).toInt(),
      ),
      weightRange: json['weight_range'] as String?,
      dimensions: json['dimensions'] as String?,
      isMobile: json['is_mobile'] as bool? ?? true,
      schematicIcon: json['schematic_icon'] as String?,
      archivedAt: json['archived_at'] == null
          ? null
          : DateTime.parse(json['archived_at'] as String),
      archivedBy: json['archived_by'] as String?,
      archivedReason: json['archived_reason'] as String?,
    );

Map<String, dynamic> _$$EquipmentTypeImplToJson(_$EquipmentTypeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'category': const EquipmentCategoryConverter().toJson(instance.category),
      'weight_range': instance.weightRange,
      'dimensions': instance.dimensions,
      'is_mobile': instance.isMobile,
      'schematic_icon': instance.schematicIcon,
      'archived_at': instance.archivedAt?.toIso8601String(),
      'archived_by': instance.archivedBy,
      'archived_reason': instance.archivedReason,
    };
