// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anthropometry_measurement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AnthropometryMeasurementImpl _$$AnthropometryMeasurementImplFromJson(
        Map<String, dynamic> json) =>
    _$AnthropometryMeasurementImpl(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      dateTime: DateTime.parse(json['date_time'] as String),
      weight: (json['weight'] as num).toDouble(),
      shouldersCirc: (json['shoulders_circ'] as num).toInt(),
      breastCirc: (json['breast_circ'] as num).toInt(),
      waistCirc: (json['waist_circ'] as num).toInt(),
      hipsCirc: (json['hips_circ'] as num).toInt(),
      fatPercentage: (json['fat_percentage'] as num?)?.toDouble(),
      muscleMass: (json['muscle_mass'] as num?)?.toDouble(),
      companyId: json['company_id'] as String?,
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

Map<String, dynamic> _$$AnthropometryMeasurementImplToJson(
        _$AnthropometryMeasurementImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'date_time': instance.dateTime.toIso8601String(),
      'weight': instance.weight,
      'shoulders_circ': instance.shouldersCirc,
      'breast_circ': instance.breastCirc,
      'waist_circ': instance.waistCirc,
      'hips_circ': instance.hipsCirc,
      'fat_percentage': instance.fatPercentage,
      'muscle_mass': instance.muscleMass,
      'company_id': instance.companyId,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'created_by': instance.createdBy,
      'updated_by': instance.updatedBy,
      'archived_at': instance.archivedAt?.toIso8601String(),
      'archived_by': instance.archivedBy,
      'archived_reason': instance.archivedReason,
    };
