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
      level: $enumDecode(_$CompetencyLevelEnumMap, json['level']),
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
      'level': _$CompetencyLevelEnumMap[instance.level]!,
      'certificate_url': instance.certificateUrl,
      'verified_at': instance.verifiedAt?.toIso8601String(),
      'verified_by': instance.verifiedBy,
    };

const _$ExecutorTypeEnumMap = {
  ExecutorType.user: 'user',
  ExecutorType.staff: 'staff',
};

const _$CompetencyLevelEnumMap = {
  CompetencyLevel.trainee: 'trainee',
  CompetencyLevel.junior: 'junior',
  CompetencyLevel.middle: 'middle',
  CompetencyLevel.senior: 'senior',
  CompetencyLevel.expert: 'expert',
};
