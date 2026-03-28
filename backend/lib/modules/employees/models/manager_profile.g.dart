// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manager_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ManagerProfile _$ManagerProfileFromJson(Map<String, dynamic> json) =>
    ManagerProfile(
      userId: json['user_id'] as String,
      isDuty: json['is_duty'] as bool? ?? false,
    );

Map<String, dynamic> _$ManagerProfileToJson(ManagerProfile instance) =>
    <String, dynamic>{'user_id': instance.userId, 'is_duty': instance.isDuty};
