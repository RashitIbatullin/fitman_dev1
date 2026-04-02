// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repair_time_standard.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RepairTimeStandardImpl _$$RepairTimeStandardImplFromJson(
  Map<String, dynamic> json,
) => _$RepairTimeStandardImpl(
  id: json['id'] as String?,
  name: json['name'] as String,
  equipmentTypeId: json['equipment_type_id'] as String,
  description: json['description'] as String?,
  standardDurationHours: (json['standard_duration_hours'] as num).toDouble(),
  complexity: $enumDecodeNullable(
    _$RepairComplexityEnumMap,
    json['complexity'],
  ),
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
);

Map<String, dynamic> _$$RepairTimeStandardImplToJson(
  _$RepairTimeStandardImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'equipment_type_id': instance.equipmentTypeId,
  'description': instance.description,
  'standard_duration_hours': instance.standardDurationHours,
  'complexity': _$RepairComplexityEnumMap[instance.complexity],
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
  'created_by': instance.createdBy,
  'updated_by': instance.updatedBy,
  'archived_at': instance.archivedAt?.toIso8601String(),
  'archived_by': instance.archivedBy,
  'archived_reason': instance.archivedReason,
};

const _$RepairComplexityEnumMap = {
  RepairComplexity.low: 'low',
  RepairComplexity.medium: 'medium',
  RepairComplexity.high: 'high',
};
