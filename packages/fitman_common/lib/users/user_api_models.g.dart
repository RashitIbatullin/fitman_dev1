// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_api_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) => AuthResponse(
      token: json['token'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AuthResponseToJson(AuthResponse instance) =>
    <String, dynamic>{
      'token': instance.token,
      'user': instance.user.toJson(),
    };

CreateUserRequest _$CreateUserRequestFromJson(Map<String, dynamic> json) =>
    CreateUserRequest(
      email: json['email'] as String,
      password: json['password'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      roles: (json['roles'] as List<dynamic>).map((e) => e as String).toList(),
      middleName: json['middle_name'] as String?,
      phone: json['phone'] as String?,
      gender: json['gender'] as String?,
      dateOfBirth: json['date_of_birth'] == null
          ? null
          : DateTime.parse(json['date_of_birth'] as String),
      sendNotification: json['send_notification'] as bool? ?? true,
      hourNotification: (json['hour_notification'] as num?)?.toInt() ?? 1,
      clientProfile: json['client_profile'] as Map<String, dynamic>?,
      employeeProfile: json['employee_profile'] as Map<String, dynamic>?,
      instructorProfile: json['instructor_profile'] as Map<String, dynamic>?,
      managerProfile: json['manager_profile'] as Map<String, dynamic>?,
      trainerProfile: json['trainer_profile'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$CreateUserRequestToJson(CreateUserRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'roles': instance.roles,
      'middle_name': instance.middleName,
      'phone': instance.phone,
      'gender': instance.gender,
      'date_of_birth': instance.dateOfBirth?.toIso8601String(),
      'send_notification': instance.sendNotification,
      'hour_notification': instance.hourNotification,
      'client_profile': instance.clientProfile,
      'employee_profile': instance.employeeProfile,
      'instructor_profile': instance.instructorProfile,
      'manager_profile': instance.managerProfile,
      'trainer_profile': instance.trainerProfile,
    };

UpdateUserRequest _$UpdateUserRequestFromJson(Map<String, dynamic> json) =>
    UpdateUserRequest(
      id: json['id'] as String,
      email: json['email'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      middleName: json['middle_name'] as String?,
      phone: json['phone'] as String?,
      gender: json['gender'] as String?,
      dateOfBirth: json['date_of_birth'] == null
          ? null
          : DateTime.parse(json['date_of_birth'] as String),
      clientProfile: json['client_profile'] as Map<String, dynamic>?,
      employeeProfile: json['employee_profile'] as Map<String, dynamic>?,
      instructorProfile: json['instructor_profile'] as Map<String, dynamic>?,
      managerProfile: json['manager_profile'] as Map<String, dynamic>?,
      trainerProfile: json['trainer_profile'] as Map<String, dynamic>?,
      archivedAt: json['archived_at'] == null
          ? null
          : DateTime.parse(json['archived_at'] as String),
      archivedReason: json['archived_reason'] as String?,
    );

Map<String, dynamic> _$UpdateUserRequestToJson(UpdateUserRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'middle_name': instance.middleName,
      'phone': instance.phone,
      'gender': instance.gender,
      'date_of_birth': instance.dateOfBirth?.toIso8601String(),
      'client_profile': instance.clientProfile,
      'employee_profile': instance.employeeProfile,
      'instructor_profile': instance.instructorProfile,
      'manager_profile': instance.managerProfile,
      'trainer_profile': instance.trainerProfile,
      'archived_at': instance.archivedAt?.toIso8601String(),
      'archived_reason': instance.archivedReason,
    };
