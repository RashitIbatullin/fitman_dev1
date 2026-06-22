// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_group_user_remove.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TrainingGroupUserRemoveImpl _$$TrainingGroupUserRemoveImplFromJson(
  Map<String, dynamic> json,
) => _$TrainingGroupUserRemoveImpl(
  id: json['id'] as String?,
  groupId: json['group_id'] as String,
  userId: json['user_id'] as String,
  userRole: json['user_role'] as String,
  removedAt: const CustomDateTimeConverter().fromJson(
    json['removed_at'] as Object,
  ),
  reason: json['reason'] as String,
  initiatorId: json['initiator_id'] as String,
  createdAt: const NullableCustomDateTimeConverter().fromJson(
    json['created_at'],
  ),
);

Map<String, dynamic> _$$TrainingGroupUserRemoveImplToJson(
  _$TrainingGroupUserRemoveImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'group_id': instance.groupId,
  'user_id': instance.userId,
  'user_role': instance.userRole,
  'removed_at': const CustomDateTimeConverter().toJson(instance.removedAt),
  'reason': instance.reason,
  'initiator_id': instance.initiatorId,
  'created_at': const NullableCustomDateTimeConverter().toJson(
    instance.createdAt,
  ),
};
