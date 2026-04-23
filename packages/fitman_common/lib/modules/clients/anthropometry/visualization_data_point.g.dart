// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visualization_data_point.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VisualizationDataPointImpl _$$VisualizationDataPointImplFromJson(
        Map<String, dynamic> json) =>
    _$VisualizationDataPointImpl(
      dateTime: DateTime.parse(json['date_time'] as String),
      weight: (json['weight'] as num).toDouble(),
      shouldersCirc: (json['shoulders_circ'] as num).toInt(),
      breastCirc: (json['breast_circ'] as num).toInt(),
      waistCirc: (json['waist_circ'] as num).toInt(),
      hipsCirc: (json['hips_circ'] as num).toInt(),
      fatPercentage: (json['fat_percentage'] as num?)?.toDouble(),
      muscleMass: (json['muscle_mass'] as num?)?.toDouble(),
      whtrRatio: (json['whtr_ratio'] as num?)?.toDouble(),
      bmr: (json['bmr'] as num?)?.toDouble(),
      tdee: (json['tdee'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$VisualizationDataPointImplToJson(
        _$VisualizationDataPointImpl instance) =>
    <String, dynamic>{
      'date_time': instance.dateTime.toIso8601String(),
      'weight': instance.weight,
      'shoulders_circ': instance.shouldersCirc,
      'breast_circ': instance.breastCirc,
      'waist_circ': instance.waistCirc,
      'hips_circ': instance.hipsCirc,
      'fat_percentage': instance.fatPercentage,
      'muscle_mass': instance.muscleMass,
      'whtr_ratio': instance.whtrRatio,
      'bmr': instance.bmr,
      'tdee': instance.tdee,
    };
