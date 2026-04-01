// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calorie_tracking_data.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CalorieTrackingDataImpl _$$CalorieTrackingDataImplFromJson(
        Map<String, dynamic> json) =>
    _$CalorieTrackingDataImpl(
      date: DateTime.parse(json['date'] as String),
      training: json['training'] as String,
      consumed: (json['consumed'] as num).toInt(),
      burned: (json['burned'] as num).toInt(),
      balance: (json['balance'] as num).toInt(),
    );

Map<String, dynamic> _$$CalorieTrackingDataImplToJson(
        _$CalorieTrackingDataImpl instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'training': instance.training,
      'consumed': instance.consumed,
      'burned': instance.burned,
      'balance': instance.balance,
    };
