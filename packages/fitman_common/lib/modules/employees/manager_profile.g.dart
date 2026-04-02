// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manager_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ManagerProfileImpl _$$ManagerProfileImplFromJson(Map<String, dynamic> json) =>
    _$ManagerProfileImpl(
      userId: json['user_id'] as String,
      isDuty: json['is_duty'] as bool? ?? false,
    );

Map<String, dynamic> _$$ManagerProfileImplToJson(
        _$ManagerProfileImpl instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'is_duty': instance.isDuty,
    };
