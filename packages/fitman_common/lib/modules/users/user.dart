import '../employees/employee_profile.dart';
import '../employees/instructor_profile.dart';
import '../employees/manager_profile.dart';
import '../employees/trainer_profile.dart';
import '../roles/role.dart';
import 'client_profile.dart';

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
    return User(
      id: json['id'].toString(),
      email: json['email'] ?? json['login'],
      passwordHash: json['passwordHash'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      middleName: json['middleName'],
      photoUrl: json['photoUrl'],
      roles: (json['roles'] as List<dynamic>?)
              ?.map((roleMap) => Role.fromJson(roleMap as Map<String, dynamic>))
              .toList() ??
          [],
      phone: json['phone'],
      gender: json['gender'],
      dateOfBirth: json['dateOfBirth'] != null ? DateTime.parse(json['dateOfBirth']) : null,
      sendNotification: json['sendNotification'] ?? true,
      hourNotification: (json['hourNotification'] as num?)?.toInt() ?? 1,
      clientProfile: json['client_profile'] != null
          ? ClientProfile.fromJson(json['client_profile'])
          : null,
      employeeProfile: json['employee_profile'] != null
          ? EmployeeProfile.fromJson(json['employee_profile'])
          : null,
      instructorProfile: json['instructor_profile'] != null
          ? InstructorProfile.fromJson(json['instructor_profile'])
          : null,
      trainerProfile: json['trainer_profile'] != null
          ? TrainerProfile.fromJson(json['trainer_profile'])
          : null,
      managerProfile: json['manager_profile'] != null
          ? ManagerProfile.fromJson(json['manager_profile'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      archivedAt: json['archivedAt'] != null ? DateTime.parse(json['archivedAt'] as String) : null,
      archivedReason: json['archivedReason'] as String?,
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
      'firstName': firstName,
      'lastName': lastName,
      'middleName': middleName,
      'photoUrl': photoUrl,
      'roles': roles.map((r) => r.toJson()).toList(),
      'phone': phone,
      'gender': gender,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'sendNotification': sendNotification,
      'hourNotification': hourNotification,
      'client_profile': clientProfile?.toJson(),
      'employee_profile': employeeProfile?.toJson(),
      'instructor_profile': instructorProfile?.toJson(),
      'trainer_profile': trainerProfile?.toJson(),
      'manager_profile': managerProfile?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'archivedAt': archivedAt?.toIso8601String(),
      'archivedReason': archivedReason,
    };
  }
}
