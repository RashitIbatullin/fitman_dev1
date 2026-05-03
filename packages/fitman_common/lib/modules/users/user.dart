import '../employees/employee_profile.dart';
import '../employees/instructor_profile.dart';
import '../employees/manager_profile.dart';
import '../employees/trainer_profile.dart';
import '../roles/role.dart';
import 'client_profile.dart';

// Helper functions for DateTime parsing
DateTime? _parseNullableDateTime(dynamic date) {
  if (date == null) return null;
  if (date is DateTime) return date;
  if (date is String) return DateTime.tryParse(date);
  return null;
}

DateTime _parseDateTime(dynamic date, String fieldName) {
  final parsed = _parseNullableDateTime(date);
  if (parsed == null) {
    throw ArgumentError('Invalid or missing date value for required field: $fieldName');
  }
  return parsed;
}

// --- Main User Model ---
class User {
  final String id;
  final String email;
  final String passwordHash;
  final String firstName;
  final String lastName;
  final String? middleName;
  final String? photoUrl;
  final List<Role> roles;
  final String? phone;
  final String? gender;
  final DateTime? dateOfBirth;
  final bool sendNotification;
  final int hourNotification;
  final ClientProfile? clientProfile;
  final EmployeeProfile? employeeProfile;
  final InstructorProfile? instructorProfile;
  final TrainerProfile? trainerProfile;
  final ManagerProfile? managerProfile;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? archivedAt;
  final String? archivedReason;

  User({
    required this.id,
    required this.email,
    required this.passwordHash,
    required this.firstName,
    required this.lastName,
    this.middleName,
    this.photoUrl,
    required this.roles,
    this.phone,
    this.gender,
    this.dateOfBirth,
    this.sendNotification = true,
    this.hourNotification = 1,
    this.clientProfile,
    this.employeeProfile,
    this.instructorProfile,
    this.trainerProfile,
    this.managerProfile,
    required this.createdAt,
    required this.updatedAt,
    this.archivedAt,
    this.archivedReason,
  });

  factory User.fromMap(Map<String, dynamic> map) => User.fromJson(map);

  factory User.fromJson(Map<String, dynamic> json) {
    // This constructor assumes 'id' is present and roles are maps (from DB or direct API)
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      passwordHash: json['password_hash'] as String? ?? '', // Provide default empty string
      firstName: json['first_name'] as String? ?? '',       // Provide default empty string
      lastName: json['last_name'] as String? ?? '',         // Provide default empty string
      middleName: json['middle_name'] as String?,
      photoUrl: json['photo_url'] as String?,
      roles: (json['roles'] as List<dynamic>?)
              ?.map((roleMap) => Role.fromJson(roleMap as Map<String, dynamic>))
              .toList() ??
          [],
      phone: json['phone'] as String?,
      gender: json['gender'] is int ? (json['gender'] == 0 ? 'мужской' : 'женский') : json['gender'] as String?,
      dateOfBirth: _parseNullableDateTime(json['date_of_birth']),
      sendNotification: json['send_notification'] as bool? ?? true,
      hourNotification: (json['hour_notification'] as num?)?.toInt() ?? 1,
      clientProfile: json['client_profile'] != null
          ? ClientProfile.fromJson(json['client_profile'] as Map<String, dynamic>)
          : null,
      employeeProfile: json['employee_profile'] != null
          ? EmployeeProfile.fromJson(json['employee_profile'] as Map<String, dynamic>)
          : null,
      instructorProfile: json['instructor_profile'] != null
          ? InstructorProfile.fromJson(json['instructor_profile'] as Map<String, dynamic>)
          : null,
      trainerProfile: json['trainer_profile'] != null
          ? TrainerProfile.fromJson(json['trainer_profile'] as Map<String, dynamic>)
          : null,
      managerProfile: json['manager_profile'] != null
          ? ManagerProfile.fromJson(json['manager_profile'] as Map<String, dynamic>)
          : null,
      createdAt: json.containsKey('created_at') ? _parseDateTime(json['created_at'], 'created_at') : DateTime.now(),
      updatedAt: json.containsKey('updated_at') ? _parseDateTime(json['updated_at'], 'updated_at') : DateTime.now(),
      archivedAt: _parseNullableDateTime(json['archived_at']),
      archivedReason: json['archived_reason'],
    );
  }

  factory User.fromJwt(Map<String, dynamic> json) {
    // This constructor handles JWT-specific fields like 'userId' and 'roles' as string list
    return User(
      id: json['userId'] as String, // From JWT payload
      email: json['email'] as String,
      passwordHash: json['password_hash'] ?? '', // JWT might not have passwordHash
      firstName: json['firstName'] ?? '', // From JWT
      lastName: json['lastName'] ?? '', // From JWT
      middleName: json['middleName'] as String?, // From JWT
      photoUrl: json['photo_url'],
      roles: (json['roles'] as List<dynamic>?) // From JWT payload as list of strings
              ?.map((role) => Role(id: '', name: role as String, title: role))
              .toList() ??
          [],
      phone: json['phone'],
      gender: json['gender'] is int ? (json['gender'] == 0 ? 'мужской' : 'женский') : json['gender'],
      dateOfBirth: _parseNullableDateTime(json['date_of_birth']),
      sendNotification: json['send_notification'] ?? true,
      hourNotification: (json['hour_notification'] as num?)?.toInt() ?? 1,
      clientProfile: json['client_profile'] != null
          ? ClientProfile.fromJson(json['client_profile'] as Map<String, dynamic>)
          : null,
      employeeProfile: json['employee_profile'] != null
          ? EmployeeProfile.fromJson(json['employee_profile'] as Map<String, dynamic>)
          : null,
      instructorProfile: json['instructor_profile'] != null
          ? InstructorProfile.fromJson(json['instructor_profile'] as Map<String, dynamic>)
          : null,
      trainerProfile: json['trainer_profile'] != null
          ? TrainerProfile.fromJson(json['trainer_profile'] as Map<String, dynamic>)
          : null,
      managerProfile: json['manager_profile'] != null
          ? ManagerProfile.fromJson(json['manager_profile'] as Map<String, dynamic>)
          : null,
      createdAt: json.containsKey('created_at') ? _parseDateTime(json['created_at'], 'created_at') : DateTime.now(),
      updatedAt: json.containsKey('updated_at') ? _parseDateTime(json['updated_at'], 'updated_at') : DateTime.now(),
      archivedAt: _parseNullableDateTime(json['archived_at']),
      archivedReason: json['archived_reason'],
    );
  }

  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  String get fullName {
    if (middleName != null && middleName!.isNotEmpty) {
      return '$lastName $firstName $middleName';
    }
    return '$lastName $firstName';
  }

  String get shortName {
    final String middleInitial = middleName != null && middleName!.isNotEmpty
        ? ' ${middleName![0]}.'
        : '';
    return '$lastName ${firstName[0]}.$middleInitial';
  }

  User copyWith({
    String? id,
    String? email,
    String? passwordHash,
    String? firstName,
    String? lastName,
    String? middleName,
    String? photoUrl,
    List<Role>? roles,
    String? phone,
    String? gender,
    DateTime? dateOfBirth,
    bool? sendNotification,
    int? hourNotification,
    ClientProfile? clientProfile,
    EmployeeProfile? employeeProfile,
    InstructorProfile? instructorProfile,
    TrainerProfile? trainerProfile,
    ManagerProfile? managerProfile,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? archivedAt,
    String? archivedReason,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      middleName: middleName ?? this.middleName,
      photoUrl: photoUrl ?? this.photoUrl,
      roles: roles ?? this.roles,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      sendNotification: sendNotification ?? this.sendNotification,
      hourNotification: hourNotification ?? this.hourNotification,
      clientProfile: clientProfile ?? this.clientProfile,
      employeeProfile: employeeProfile ?? this.employeeProfile,
      instructorProfile: instructorProfile ?? this.instructorProfile,
      trainerProfile: trainerProfile ?? this.trainerProfile,
      managerProfile: managerProfile ?? this.managerProfile,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: archivedAt ?? this.archivedAt,
      archivedReason: archivedReason ?? this.archivedReason,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'middle_name': middleName,
      'photo_url': photoUrl,
      'roles': roles.map((r) => r.toJson()).toList(),
      'phone': phone,
      'gender': gender,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'send_notification': sendNotification,
      'hour_notification': hourNotification,
      'client_profile': clientProfile?.toJson(),
      'employee_profile': employeeProfile?.toJson(),
      'instructor_profile': instructorProfile?.toJson(),
      'trainer_profile': trainerProfile?.toJson(),
      'manager_profile': managerProfile?.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'archived_at': archivedAt?.toIso8601String(),
      'archived_reason': archivedReason,
    };
  }
}
