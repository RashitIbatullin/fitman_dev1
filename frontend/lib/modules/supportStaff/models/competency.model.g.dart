// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'competency.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CompetencyImpl _$$CompetencyImplFromJson(Map<String, dynamic> json) =>
    _$CompetencyImpl(
      id: json['id'] as String,
      staffId: json['staff_id'] as String,
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
      'staff_id': instance.staffId,
      'name': instance.name,
      'level': instance.level,
      'certificate_url': instance.certificateUrl,
      'verified_at': instance.verifiedAt?.toIso8601String(),
      'verified_by': instance.verifiedBy,
    };
