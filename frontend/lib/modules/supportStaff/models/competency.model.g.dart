// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'competency.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CompetencyImpl _$$CompetencyImplFromJson(Map<String, dynamic> json) =>
    _$CompetencyImpl(
      id: json['id'] as String,
      competentId: json['competent_id'] as String,
      executorType: $enumDecode(_$ExecutorTypeEnumMap, json['executor_type']),
      name: json['name'] as String,
      level: (json['level'] as num).toInt(),
      certificateUrl: json['certificate_url'] as String?,
      verifiedAt: json['verified_at'] == null
          ? null
          : DateTime.parse(json['verified_at'] as String),
      verifiedBy: json['verified_by'] as String?,
    );

Map<String, dynamic> _$$CompetencyImplToJson(_$CompetencyImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'competent_id': instance.competentId,
      'executor_type': _$ExecutorTypeEnumMap[instance.executorType]!,
      'name': instance.name,
      'level': instance.level,
      'certificate_url': instance.certificateUrl,
      'verified_at': instance.verifiedAt?.toIso8601String(),
      'verified_by': instance.verifiedBy,
    };

const _$ExecutorTypeEnumMap = {
  ExecutorType.user: 'user',
  ExecutorType.staff: 'staff',
};
