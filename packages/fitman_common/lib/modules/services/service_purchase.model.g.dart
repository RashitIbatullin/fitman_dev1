// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_purchase.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ServicePurchaseImpl _$$ServicePurchaseImplFromJson(
  Map<String, dynamic> json,
) => _$ServicePurchaseImpl(
  id: json['id'] as String,
  clientId: json['client_id'] as String,
  clientName: json['client_name'] as String?,
  serviceId: json['service_id'] as String,
  serviceName: json['service_name'] as String,
  serviceCode: json['service_code'] as String?,
  serviceTypeCode: json['service_type_code'] as String?,
  serviceTypeTitle: json['service_type_title'] as String?,
  executorSpecializationCode: json['executor_specialization_code'] as String?,
  executorSpecializationTitle: json['executor_specialization_title'] as String?,
  purchasePrice: (json['purchase_price'] as num?)?.toDouble(),
  discountPercent: (json['discount_percent'] as num).toDouble(),
  discountAmount: (json['discount_amount'] as num).toDouble(),
  finalPrice: (json['final_price'] as num?)?.toDouble(),
  paymentStatus: (json['payment_status'] as num).toInt(),
  paymentSource: (json['payment_source'] as num?)?.toInt(),
  purchaseDate: DateTime.parse(json['purchase_date'] as String),
  activationDate: json['activation_date'] == null
      ? null
      : DateTime.parse(json['activation_date'] as String),
  expiryDate: json['expiry_date'] == null
      ? null
      : DateTime.parse(json['expiry_date'] as String),
  actualExpiryDate: json['actual_expiry_date'] == null
      ? null
      : DateTime.parse(json['actual_expiry_date'] as String),
  totalUses: (json['total_uses'] as num?)?.toInt(),
  usedUses: (json['used_uses'] as num).toInt(),
  remainingUses: (json['remaining_uses'] as num?)?.toInt(),
  status: (json['status'] as num).toInt(),
  quotaUsed: (json['quota_used'] as num?)?.toInt(),
  quotaLimit: (json['quota_limit'] as num?)?.toInt(),
  quotaPeriod: (json['quota_period'] as num?)?.toInt(),
  quotaPeriodStart: json['quota_period_start'] == null
      ? null
      : DateTime.parse(json['quota_period_start'] as String),
  quotaPeriodEnd: json['quota_period_end'] == null
      ? null
      : DateTime.parse(json['quota_period_end'] as String),
  usageLimitMode: (json['usage_limit_mode'] as num).toInt(),
);

Map<String, dynamic> _$$ServicePurchaseImplToJson(
  _$ServicePurchaseImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'client_id': instance.clientId,
  'client_name': instance.clientName,
  'service_id': instance.serviceId,
  'service_name': instance.serviceName,
  'service_code': instance.serviceCode,
  'service_type_code': instance.serviceTypeCode,
  'service_type_title': instance.serviceTypeTitle,
  'executor_specialization_code': instance.executorSpecializationCode,
  'executor_specialization_title': instance.executorSpecializationTitle,
  'purchase_price': instance.purchasePrice,
  'discount_percent': instance.discountPercent,
  'discount_amount': instance.discountAmount,
  'final_price': instance.finalPrice,
  'payment_status': instance.paymentStatus,
  'payment_source': instance.paymentSource,
  'purchase_date': instance.purchaseDate.toIso8601String(),
  'activation_date': instance.activationDate?.toIso8601String(),
  'expiry_date': instance.expiryDate?.toIso8601String(),
  'actual_expiry_date': instance.actualExpiryDate?.toIso8601String(),
  'total_uses': instance.totalUses,
  'used_uses': instance.usedUses,
  'remaining_uses': instance.remainingUses,
  'status': instance.status,
  'quota_used': instance.quotaUsed,
  'quota_limit': instance.quotaLimit,
  'quota_period': instance.quotaPeriod,
  'quota_period_start': instance.quotaPeriodStart?.toIso8601String(),
  'quota_period_end': instance.quotaPeriodEnd?.toIso8601String(),
  'usage_limit_mode': instance.usageLimitMode,
};
