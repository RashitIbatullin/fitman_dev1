// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'instructor_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InstructorProfileImpl _$$InstructorProfileImplFromJson(
  Map<String, dynamic> json,
) => _$InstructorProfileImpl(
  userId: (json['user_id'] as num).toInt(),
  isDuty: json['is_duty'] as bool? ?? false,
  canReplaceTrainer: json['can_replace_trainer'] as bool? ?? false,
  canCreatePlan: json['can_create_plan'] as bool? ?? false,
);

Map<String, dynamic> _$$InstructorProfileImplToJson(
  _$InstructorProfileImpl instance,
) => <String, dynamic>{
  'user_id': instance.userId,
  'is_duty': instance.isDuty,
  'can_replace_trainer': instance.canReplaceTrainer,
  'can_create_plan': instance.canCreatePlan,
};
