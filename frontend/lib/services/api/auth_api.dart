import 'package:http/http.dart' as http;

import '../../modules/roles/models/role.dart';
import '../../modules/users/models/user.dart';
import 'base_api.dart';

/// Service class for authentication and user management APIs.
class AuthApiService extends BaseApiService {
  AuthApiService({super.client});

  /// Logs in a user.
  Future<AuthResponse> login(String email, String password) async {
    final data = await post('/api/auth/login', body: {'email': email, 'password': password});
    final token = data['token']?.toString() ?? '';
    final userData = data['user'] ?? {};

    if (token.isEmpty) {
      throw Exception('No token received from server');
    }

    final user = User.fromJson(userData);
    return AuthResponse(token: token, user: user);
  }

  /// Registers a new user.
  Future<AuthResponse> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required List<String> roles,
    String? phone,
    String? gender,
    DateTime? dateOfBirth,
  }) async {
    final data = await post('/api/auth/register', body: {
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'roles': roles,
      'phone': phone,
      'gender': gender,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
    });

    final token = data['token']?.toString() ?? '';
    final userData = data['user'] ?? {};

    if (token.isEmpty) {
      throw Exception('No token received from server');
    }

    final user = User.fromJson(userData);
    return AuthResponse(token: token, user: user);
  }

  /// Checks the current token and retrieves the associated user.
  Future<User> checkTokenAndGetUser() async {
    if (BaseApiService.currentToken == null) await BaseApiService.init();
    if (BaseApiService.currentToken == null) throw Exception('No token available');

    final data = await get('/api/auth/check');
    return User.fromJson(data['user']);
  }

  /// Creates a new user (admin).
  Future<User> createUser(CreateUserRequest request) async {
    final data = await post('/api/users', body: request.toJson());
    return User.fromJson(data['user']);
  }

  /// Updates an existing user (admin).
  Future<User> updateUser(UpdateUserRequest request) async {
    final data = await put('/api/users/${request.id}', body: request.toJson());
    return User.fromJson(data['user']);
  }

  /// Fetches a list of users with optional filters.
  Future<List<User>> getUsers({String? role, int? offset, int? limit, bool? isArchived}) async {
    final queryParams = <String, String>{};
    if (role != null) queryParams['role'] = role;
    if (isArchived != null) queryParams['isArchived'] = isArchived.toString();
    if (offset != null) queryParams['offset'] = offset.toString();
    if (limit != null) queryParams['limit'] = limit.toString();

    final data = await get('/api/users', queryParams: queryParams.isNotEmpty ? queryParams : null);
    final users = data['users'] as List;
    return users.map((userData) => User.fromJson(userData)).toList();
  }

  /// Fetches a single user by their ID.
  Future<User> getUserById(int userId) async {
    final data = await get('/api/users/$userId');
    return User.fromJson(data['user']);
  }

  /// Fetches all available roles.
  Future<List<Role>> getAllRoles() async {
    final data = await get('/api/roles');
    final roles = data['roles'] as List;
    return roles.map((roleData) => Role.fromJson(roleData)).toList();
  }

  /// Fetches the roles for a specific user.
  Future<List<Role>> getUserRoles(int userId) async {
    final data = await get('/api/users/$userId/roles');
    final roles = data['roles'] as List;
    return roles.map((roleData) => Role.fromJson(roleData)).toList();
  }

  /// Updates the roles for a specific user.
  Future<void> updateUserRoles(int userId, List<String> roleNames) async {
    await put('/api/users/$userId/roles', body: {'roles': roleNames});
  }

  /// Archives a user.
  Future<void> archiveUser(int userId, {String? reason}) async {
    final body = <String, dynamic>{'archivedAt': DateTime.now().toIso8601String()};
    if (reason != null && reason.isNotEmpty) {
      body['archivedReason'] = reason;
    }
    await put('/api/users/$userId', body: body);
  }

  /// Uploads a user's avatar.
  Future<Map<String, dynamic>> uploadAvatar(List<int> photoBytes, String fileName, int userId) async {
    final file = http.MultipartFile.fromBytes('photo', photoBytes, filename: fileName);
    return await multipartPost(
      '/api/users/$userId/avatar',
      fields: {},
      file: file,
    );
  }

  /// Resets a user's password (admin).
  Future<void> resetUserPassword(int userId, String newPassword) async {
    await post('/api/users/$userId/reset-password', body: {'password': newPassword});
  }
}