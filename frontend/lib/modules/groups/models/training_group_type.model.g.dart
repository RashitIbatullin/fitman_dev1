// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_group_type.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrainingGroupType _$TrainingGroupTypeFromJson(Map<String, dynamic> json) =>
    TrainingGroupType(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      title: json['title'] as String,
      minParticipants: (json['min_participants'] as num).toInt(),
      maxParticipants: (json['max_participants'] as num).toInt(),
      description: json['description'] as String?,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
    );

Map<String, dynamic> _$TrainingGroupTypeToJson(TrainingGroupType instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'title': instance.title,
      'min_participants': instance.minParticipants,
      'max_participants': instance.maxParticipants,
      'description': instance.description,
      'icon': instance.icon,
      'color': instance.color,
    };
