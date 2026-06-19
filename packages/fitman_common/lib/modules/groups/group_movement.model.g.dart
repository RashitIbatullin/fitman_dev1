// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_movement.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GroupMovementImpl _$$GroupMovementImplFromJson(Map<String, dynamic> json) =>
    _$GroupMovementImpl(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      fromGroupId: json['from_group_id'] as String?,
      toGroupId: json['to_group_id'] as String?,
      movementDate: const CustomDateTimeConverter().fromJson(
        json['movement_date'] as Object,
      ),
      reason: json['reason'] as String?,
      movedByUserId: json['moved_by_user_id'] as String,
      createdAt: const NullableCustomDateTimeConverter().fromJson(
        json['created_at'],
      ),
    );

Map<String, dynamic> _$$GroupMovementImplToJson(_$GroupMovementImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'from_group_id': instance.fromGroupId,
      'to_group_id': instance.toGroupId,
      'movement_date': const CustomDateTimeConverter().toJson(
        instance.movementDate,
      ),
      'reason': instance.reason,
      'moved_by_user_id': instance.movedByUserId,
      'created_at': const NullableCustomDateTimeConverter().toJson(
        instance.createdAt,
      ),
    };
