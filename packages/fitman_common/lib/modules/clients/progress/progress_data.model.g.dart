// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_data.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProgressDataImpl _$$ProgressDataImplFromJson(Map<String, dynamic> json) =>
    _$ProgressDataImpl(
      weight: (json['weight'] as List<dynamic>)
          .map((e) => ChartDataPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      calories: (json['calories'] as List<dynamic>)
          .map((e) => ChartDataPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      balance: (json['balance'] as List<dynamic>)
          .map((e) => ChartDataPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      kpi: KpiData.fromJson(json['kpi'] as Map<String, dynamic>),
      recommendations: json['recommendations'] as String,
    );

Map<String, dynamic> _$$ProgressDataImplToJson(_$ProgressDataImpl instance) =>
    <String, dynamic>{
      'weight': instance.weight,
      'calories': instance.calories,
      'balance': instance.balance,
      'kpi': instance.kpi,
      'recommendations': instance.recommendations,
    };

_$ChartDataPointImpl _$$ChartDataPointImplFromJson(Map<String, dynamic> json) =>
    _$ChartDataPointImpl(
      date: DateTime.parse(json['date'] as String),
      value: (json['value'] as num).toDouble(),
    );

Map<String, dynamic> _$$ChartDataPointImplToJson(
        _$ChartDataPointImpl instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'value': instance.value,
    };

_$KpiDataImpl _$$KpiDataImplFromJson(Map<String, dynamic> json) =>
    _$KpiDataImpl(
      avgWeight: (json['avg_weight'] as num).toDouble(),
      weightChange: (json['weight_change'] as num).toDouble(),
      avgCalories: (json['avg_calories'] as num).toInt(),
    );

Map<String, dynamic> _$$KpiDataImplToJson(_$KpiDataImpl instance) =>
    <String, dynamic>{
      'avg_weight': instance.avgWeight,
      'weight_change': instance.weightChange,
      'avg_calories': instance.avgCalories,
    };
