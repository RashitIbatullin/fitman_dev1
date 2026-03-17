// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EmployeeProfileImpl _$$EmployeeProfileImplFromJson(
  Map<String, dynamic> json,
) => _$EmployeeProfileImpl(
  userId: (json['user_id'] as num).toInt(),
  specialization: json['specialization'] as String?,
  workExperience: (json['work_experience'] as num?)?.toInt(),
  canMaintainEquipment: json['can_maintain_equipment'] as bool? ?? false,
);

Map<String, dynamic> _$$EmployeeProfileImplToJson(
  _$EmployeeProfileImpl instance,
) => <String, dynamic>{
  'user_id': instance.userId,
  'specialization': instance.specialization,
  'work_experience': instance.workExperience,
  'can_maintain_equipment': instance.canMaintainEquipment,
};
