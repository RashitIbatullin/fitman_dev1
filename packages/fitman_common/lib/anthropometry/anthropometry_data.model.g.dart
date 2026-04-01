// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anthropometry_data.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AnthropometryDataImpl _$$AnthropometryDataImplFromJson(
        Map<String, dynamic> json) =>
    _$AnthropometryDataImpl(
      fixed: AnthropometryFixed.fromJson(json['fixed'] as Map<String, dynamic>),
      start: AnthropometryMeasurements.fromJson(
          json['start'] as Map<String, dynamic>),
      finish: AnthropometryMeasurements.fromJson(
          json['finish'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$AnthropometryDataImplToJson(
        _$AnthropometryDataImpl instance) =>
    <String, dynamic>{
      'fixed': instance.fixed,
      'start': instance.start,
      'finish': instance.finish,
    };

_$AnthropometryFixedImpl _$$AnthropometryFixedImplFromJson(
        Map<String, dynamic> json) =>
    _$AnthropometryFixedImpl(
      height: (json['height'] as num?)?.toInt(),
      wristCirc: (json['wrist_circ'] as num?)?.toInt(),
      ankleCirc: (json['ankle_circ'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$AnthropometryFixedImplToJson(
        _$AnthropometryFixedImpl instance) =>
    <String, dynamic>{
      'height': instance.height,
      'wrist_circ': instance.wristCirc,
      'ankle_circ': instance.ankleCirc,
    };

_$AnthropometryMeasurementsImpl _$$AnthropometryMeasurementsImplFromJson(
        Map<String, dynamic> json) =>
    _$AnthropometryMeasurementsImpl(
      weight: (json['weight'] as num?)?.toDouble(),
      shouldersCirc: (json['shoulders_circ'] as num?)?.toInt(),
      breastCirc: (json['breast_circ'] as num?)?.toInt(),
      waistCirc: (json['waist_circ'] as num?)?.toInt(),
      hipsCirc: (json['hips_circ'] as num?)?.toInt(),
      photo: json['photo'] as String?,
      photoDateTime: json['photo_date_time'] == null
          ? null
          : DateTime.parse(json['photo_date_time'] as String),
      profilePhoto: json['profile_photo'] as String?,
      profilePhotoDateTime: json['profile_photo_date_time'] == null
          ? null
          : DateTime.parse(json['profile_photo_date_time'] as String),
    );

Map<String, dynamic> _$$AnthropometryMeasurementsImplToJson(
        _$AnthropometryMeasurementsImpl instance) =>
    <String, dynamic>{
      'weight': instance.weight,
      'shoulders_circ': instance.shouldersCirc,
      'breast_circ': instance.breastCirc,
      'waist_circ': instance.waistCirc,
      'hips_circ': instance.hipsCirc,
      'photo': instance.photo,
      'photo_date_time': instance.photoDateTime?.toIso8601String(),
      'profile_photo': instance.profilePhoto,
      'profile_photo_date_time':
          instance.profilePhotoDateTime?.toIso8601String(),
    };
