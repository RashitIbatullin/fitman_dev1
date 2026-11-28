// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ServiceImpl _$$ServiceImplFromJson(
  Map<String, dynamic> json,
) => _$ServiceImpl(
  id: json['id'] as String,
  code: json['code'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  serviceTypeId: json['service_type_id'] as String,
  serviceTypeCode: json['service_type_code'] as String,
  serviceTypeTitle: json['service_type_title'] as String,
  basePrice: (json['base_price'] as num?)?.toDouble(),
  currency: json['currency'] as String,
  durationDays: (json['duration_days'] as num?)?.toInt(),
  usageLimitMode: (json['usage_limit_mode'] as num).toInt(),
  maxUses: (json['max_uses'] as num?)?.toInt(),
  quotaPeriod: (json['quota_period'] as num?)?.toInt(),
  quotaLimit: (json['quota_limit'] as num?)?.toInt(),
  durationMinutes: (json['duration_minutes'] as num?)?.toInt(),
  executorSpecializationId: json['executor_specialization_id'] as String?,
  executorSpecializationCode: json['executor_specialization_code'] as String?,
  executorSpecializationTitle: json['executor_specialization_title'] as String?,
  activationRequired: json['activation_required'] as bool,
  allowStacking: json['allow_stacking'] as bool,
  grantsAccess: json['grants_access'] as bool,
  isActive: json['is_active'] as bool,
  archivedAt: json['archived_at'] == null
      ? null
      : DateTime.parse(json['archived_at'] as String),
  archivedReason: json['archived_reason'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$$ServiceImplToJson(_$ServiceImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
      'description': instance.description,
      'service_type_id': instance.serviceTypeId,
      'service_type_code': instance.serviceTypeCode,
      'service_type_title': instance.serviceTypeTitle,
      'base_price': instance.basePrice,
      'currency': instance.currency,
      'duration_days': instance.durationDays,
      'usage_limit_mode': instance.usageLimitMode,
      'max_uses': instance.maxUses,
      'quota_period': instance.quotaPeriod,
      'quota_limit': instance.quotaLimit,
      'duration_minutes': instance.durationMinutes,
      'executor_specialization_id': instance.executorSpecializationId,
      'executor_specialization_code': instance.executorSpecializationCode,
      'executor_specialization_title': instance.executorSpecializationTitle,
      'activation_required': instance.activationRequired,
      'allow_stacking': instance.allowStacking,
      'grants_access': instance.grantsAccess,
      'is_active': instance.isActive,
      'archived_at': instance.archivedAt?.toIso8601String(),
      'archived_reason': instance.archivedReason,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
