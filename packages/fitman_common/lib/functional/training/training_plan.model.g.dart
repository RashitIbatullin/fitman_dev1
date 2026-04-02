// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_plan.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TrainingPlanImpl _$$TrainingPlanImplFromJson(Map<String, dynamic> json) =>
    _$TrainingPlanImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      goal: json['goal'] as String,
      level: json['level'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$TrainingPlanImplToJson(_$TrainingPlanImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'goal': instance.goal,
      'level': instance.level,
      'description': instance.description,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
