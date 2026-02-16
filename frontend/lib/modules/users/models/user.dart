import '../../roles/models/role.dart';
import 'client_profile.dart';

// --- Main User Model ---
class User {
  final int id;
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
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? archivedAt;
  final String? archivedReason; // Added archivedReason field

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
    required this.createdAt,
    required this.updatedAt,
    this.archivedAt,
    this.archivedReason, // Added to constructor
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'] ?? json['login'], // Accept login as fallback for email
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
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      archivedAt: json['archivedAt'] != null ? DateTime.parse(json['archivedAt'] as String) : null,
      archivedReason: json['archivedReason'] as String?, // Added to fromJson
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
    int? id,
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
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? archivedAt,
    String? archivedReason, // Added to copyWith
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: archivedAt ?? this.archivedAt,
      archivedReason: archivedReason ?? this.archivedReason, // Added to copyWith return
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
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'archivedAt': archivedAt?.toIso8601String(),
      'archivedReason': archivedReason, // Added to toJson
    };
  }
}

// --- API Helper classes ---

class AuthResponse {
  final String token;
  final User user;

  AuthResponse({required this.token, required this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

class CreateUserRequest {
  final String email;
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
  // This can be provided when creating a client
  final Map<String, dynamic>? clientProfile;

  CreateUserRequest({
    required this.email,
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
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'roles': roles,
      'sendNotification': sendNotification,
      'hourNotification': hourNotification,
    };
    if (middleName != null) data['middleName'] = middleName;
    if (phone != null) data['phone'] = phone;
    if (gender != null) data['gender'] = gender;
    if (dateOfBirth != null) data['dateOfBirth'] = dateOfBirth!.toIso8601String();
    if (clientProfile != null) data['client_profile'] = clientProfile;
    
    return data;
  }
}

class UpdateUserRequest {
  final int id;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? middleName;
  final String? phone;
  final String? gender;
  final DateTime? dateOfBirth;
  final Map<String, dynamic>? clientProfile;
  final DateTime? archivedAt;
  final String? archivedReason; // Added archivedReason to UpdateUserRequest

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
    this.archivedAt,
    this.archivedReason, // Added to constructor
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
    };
    if (email != null) data['email'] = email;
    if (firstName != null) data['firstName'] = firstName;
    if (lastName != null) data['lastName'] = lastName;
    if (middleName != null) data['middleName'] = middleName;
    if (phone != null) data['phone'] = phone;
    if (gender != null) data['gender'] = gender;
    if (dateOfBirth != null) data['dateOfBirth'] = dateOfBirth!.toIso8601String();
    if (clientProfile != null) data['client_profile'] = clientProfile;
    if (archivedAt != null) {
      data['archivedAt'] = archivedAt!.toIso8601String();
    }
    if (archivedReason != null) { // Added archivedReason to toJson
      data['archivedReason'] = archivedReason;
    }
    
    return data;
  }
}