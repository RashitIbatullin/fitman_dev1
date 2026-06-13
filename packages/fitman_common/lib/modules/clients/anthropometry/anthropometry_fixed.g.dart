// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anthropometry_fixed.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AnthropometryFixedImpl _$$AnthropometryFixedImplFromJson(
  Map<String, dynamic> json,
) => _$AnthropometryFixedImpl(
  id: json['id'] as String?,
  userId: json['user_id'] as String,
  height: (json['height'] as num).toInt(),
  wristCirc: (json['wrist_circ'] as num).toInt(),
  ankleCirc: (json['ankle_circ'] as num).toInt(),
  companyId: json['company_id'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  createdBy: json['created_by'] as String?,
  updatedBy: json['updated_by'] as String?,
);

Map<String, dynamic> _$$AnthropometryFixedImplToJson(
  _$AnthropometryFixedImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'height': instance.height,
  'wrist_circ': instance.wristCirc,
  'ankle_circ': instance.ankleCirc,
  'company_id': instance.companyId,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
  'created_by': instance.createdBy,
  'updated_by': instance.updatedBy,
};
