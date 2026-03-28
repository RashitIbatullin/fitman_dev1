// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'instructor_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InstructorProfile _$InstructorProfileFromJson(Map<String, dynamic> json) =>
    InstructorProfile(
      userId: json['user_id'] as String,
      isDuty: json['is_duty'] as bool? ?? false,
      canReplaceTrainer: json['can_replace_trainer'] as bool? ?? false,
      canCreatePlan: json['can_create_plan'] as bool? ?? false,
    );

Map<String, dynamic> _$InstructorProfileToJson(InstructorProfile instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'is_duty': instance.isDuty,
      'can_replace_trainer': instance.canReplaceTrainer,
      'can_create_plan': instance.canCreatePlan,
    };
