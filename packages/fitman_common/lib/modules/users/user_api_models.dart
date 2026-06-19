import 'package:json_annotation/json_annotation.dart';
import 'user.dart';

part 'user_api_models.g.dart';

@JsonSerializable(explicitToJson: true)
class AuthResponse {
  final String token;
  final User user;

  AuthResponse({required this.token, required this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class CreateUserRequest {
  final String? email;
  final String password;
  final String firstName;
  final String lastName;
  final List<String> roles;
  final String? middleName;
  final String? phone;
  final String? gender;
  final DateTime? dateOfBirth;
  final bool sendNotification;
  final int hourNotification;
  final Map<String, dynamic>? clientProfile;
  final Map<String, dynamic>? employeeProfile;
  final Map<String, dynamic>? instructorProfile;
  final Map<String, dynamic>? managerProfile;
  final Map<String, dynamic>? trainerProfile;

  CreateUserRequest({
    this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.roles,
    this.middleName,
    this.phone,
    this.gender,
    this.dateOfBirth,
    this.sendNotification = true,
    this.hourNotification = 1,
    this.clientProfile,
    this.employeeProfile,
    this.instructorProfile,
    this.managerProfile,
    this.trainerProfile,
  });

  factory CreateUserRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateUserRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateUserRequestToJson(this);
}

@JsonSerializable(explicitToJson: true)
class UpdateUserRequest {
  final String id;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? middleName;
  final String? phone;
  final String? gender;
  final DateTime? dateOfBirth;
  final Map<String, dynamic>? clientProfile;
  final Map<String, dynamic>? employeeProfile;
  final Map<String, dynamic>? instructorProfile;
  final Map<String, dynamic>? managerProfile;
  final Map<String, dynamic>? trainerProfile;
  final DateTime? archivedAt;
  final String? archivedReason;

  UpdateUserRequest({
    required this.id,
    this.email,
    this.firstName,
    this.lastName,
    this.middleName,
    this.phone,
    this.gender,
    this.dateOfBirth,
    this.clientProfile,
    this.employeeProfile,
    this.instructorProfile,
    this.managerProfile,
    this.trainerProfile,
    this.archivedAt,
    this.archivedReason,
  });

  factory UpdateUserRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateUserRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateUserRequestToJson(this);
}
