// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_group_replacement_employee.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TrainingGroupReplacementEmployeeImpl
_$$TrainingGroupReplacementEmployeeImplFromJson(Map<String, dynamic> json) =>
    _$TrainingGroupReplacementEmployeeImpl(
      id: json['id'] as String?,
      groupId: json['group_id'] as String,
      oldEmployeeId: json['old_employee_id'] as String?,
      newEmployeeId: json['new_employee_id'] as String?,
      date: const CustomDateTimeConverter().fromJson(json['date'] as Object),
      reason: json['reason'] as String,
      initiatorId: json['initiator_id'] as String,
    );

Map<String, dynamic> _$$TrainingGroupReplacementEmployeeImplToJson(
  _$TrainingGroupReplacementEmployeeImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'group_id': instance.groupId,
  'old_employee_id': instance.oldEmployeeId,
  'new_employee_id': instance.newEmployeeId,
  'date': const CustomDateTimeConverter().toJson(instance.date),
  'reason': instance.reason,
  'initiator_id': instance.initiatorId,
};
