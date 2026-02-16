import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf_multipart/shelf_multipart.dart';
import 'package:bcrypt/bcrypt.dart';
import '../../../config/database.dart';
import '../models/user.dart';

class UsersController {
  static final Database _db = Database();
  // ... (other methods remain the same)

  // Создать нового пользователя (только для админа)
  static Future<Response> createUser(Request request) async {
    try {
      final payload = request.context['user'] as Map<String, dynamic>?;
      if (payload == null) {
        return Response.forbidden('Not authorized.');
      }
      final creatorId = payload['userId'] as int;

      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final roles = List<String>.from(data['roles'] as List<dynamic>);

      // --- НАЧАЛО ВАЛИДАЦИИ ---
      final email = data['email'] as String?;
      final phone = data['phone'] as String?;

      if (email == null || email.isEmpty) {
        return Response(400, body: jsonEncode({'error': 'Email является обязательным полем'}));
      }

      final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegExp.hasMatch(email)) {
        return Response(400, body: jsonEncode({'error': 'Неверный формат email'}));
      }

      final existingUserByEmail = await _db.getUserByEmail(email);
      if (existingUserByEmail != null) {
        return Response(400, body: jsonEncode({'error': 'Пользователь с таким email уже существует'}));
      }

      if (phone != null && phone.isNotEmpty) {
        final phoneRegExp = RegExp(r'^\+?[0-9\s-]{7,15}$');
        if (!phoneRegExp.hasMatch(phone)) {
          return Response(400, body: jsonEncode({'error': 'Неверный формат телефона'}));
        }
        final existingUserByPhone = await _db.getUserByPhone(phone);
        if (existingUserByPhone != null) {
          return Response(400, body: jsonEncode({'error': 'Пользователь с таким телефоном уже существует'}));
        }
      }

      if (roles.contains('client') && roles.length > 1) {
        return Response(400, body: jsonEncode({'error': 'Пользователь с ролью "Клиент" не может иметь другие роли.'}));
      }
      if (roles.any((r) => r != 'client') && roles.contains('client')) {
         return Response(400, body: jsonEncode({'error': 'Роль "Клиент" не может быть совмещена с другими ролями.'}));
      }
      // --- КОНЕЦ ВАЛИДАЦИИ ---

      final password = data['password'] as String;
      final firstName = data['firstName'] as String;
      final lastName = data['lastName'] as String;
      final gender = data['gender'] as String?;
      final dateOfBirthString = data['dateOfBirth'] as String?;
      final dateOfBirth = dateOfBirthString != null ? DateTime.parse(dateOfBirthString) : null;

      final passwordHash = BCrypt.hashpw(password, BCrypt.gensalt());

      final newUser = User(
        id: 0,
        email: email,
        passwordHash: passwordHash,
        firstName: firstName,
        lastName: lastName,
        roles: [], // Будет заполнено в методе БД
        phone: phone,
        gender: gender,
        dateOfBirth: dateOfBirth,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final createdUser = await _db.createUser(newUser, roles, creatorId);

      return Response(201, body: jsonEncode({
        'message': 'Пользователь успешно создан',
        'user': createdUser.toSafeJson()
      }));
    } catch (e) {
      print('Create user error: $e');
      return Response(500, body: jsonEncode({'error': 'Внутренняя ошибка сервера: $e'}));
    }
  }

  // Обновить роли пользователя (только для админа)
  static Future<Response> updateUserRoles(Request request, String id) async {
    try {
      final userId = int.tryParse(id);
      if (userId == null) {
        return Response(400, body: jsonEncode({'error': 'Неверный ID пользователя'}));
      }

      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final newRoleNames = List<String>.from(data['roles'] as List<dynamic>);

      final user = await _db.getUserById(userId);
      if (user == null) {
        return Response(404, body: jsonEncode({'error': 'Пользователь не найден'}));
      }

      // --- НАЧАЛО ВАЛИДАЦИИ РОЛЕЙ ---
      if (newRoleNames.contains('client') && newRoleNames.length > 1) {
        return Response(400, body: jsonEncode({'error': 'Пользователь с ролью "Клиент" не может иметь другие роли.'}));
      }
      final hasClientRole = user.roles.any((r) => r.name == 'client');
      if (hasClientRole && newRoleNames.any((name) => name != 'client')) {
        return Response(400, body: jsonEncode({'error': 'Роль "Клиент" не может быть совмещена с другими ролями.'}));
      }
      if (newRoleNames.contains('client') && user.roles.any((r) => r.name != 'client')) {
        return Response(400, body: jsonEncode({'error': 'Нельзя добавить роль "Клиент" к существующим ролям сотрудников.'}));
      }

      // Нельзя удалить основную (единственную) роль
      if (user.roles.length == 1 && !newRoleNames.contains(user.roles.first.name)) {
        return Response(400, body: jsonEncode({'error': 'Нельзя удалить основную (единственную) роль пользователя.'}));
      }
      if (newRoleNames.isEmpty) {
        return Response(400, body: jsonEncode({'error': 'У пользователя должна быть хотя бы одна роль.'}));
      }
      // --- КОНЕЦ ВАЛИДАЦИИ РОЛЕЙ ---

      // Преобразуем имена ролей в ID
      final allRoles = await _db.getAllRoles();
      final newRoleIds = newRoleNames.map((name) {
        return allRoles.firstWhere((role) => role.name == name).id;
      }).toList();

      await _db.updateUserRoles(userId, newRoleIds);

      final updatedUser = await _db.getUserById(userId);

      return Response.ok(jsonEncode({
        'message': 'Роли пользователя успешно обновлены',
        'user': updatedUser?.toSafeJson()
      }));
    } catch (e) {
      print('Update user roles error: $e');
      return Response(500, body: jsonEncode({'error': 'Внутренняя ошибка сервера: $e'}));
    }
  }

  // ... (other methods remain the same)

  // The following are the existing methods from the original file to be preserved.
  static Future<Response> getUsers(Request request) async {
    try {
      final queryParams = request.url.queryParameters;
      final bool? isArchived = queryParams['isArchived'] != null ? bool.parse(queryParams['isArchived']!) : null;
      final String? role = queryParams['role']; // Get role from query parameters

      final users = await _db.getAllUsers(isArchived: isArchived, role: role); // Pass role to getAllUsers
      final usersJson = users.map((user) => user.toSafeJson()).toList();
      return Response.ok(jsonEncode({'users': usersJson}));
    } catch (e) {
      print('Get users error: $e');
      return Response(500, body: jsonEncode({'error': 'Internal server error'}));
    }
  }

  static Future<Response> getUserById(Request request, String id) async {
    try {
      final userId = int.tryParse(id);
      if (userId == null) {
        return Response(400, body: jsonEncode({'error': 'Invalid user ID'}));
      }
      final user = await _db.getUserById(userId);
      if (user == null) {
        return Response(404, body: jsonEncode({'error': 'User not found'}));
      }
      return Response.ok(jsonEncode({'user': user.toSafeJson()}));
    } catch (e) {
      print('Get user by ID error: $e');
      return Response(500, body: jsonEncode({'error': 'Internal server error'}));
    }
  }

  static Future<Response> updateUser(Request request, String id) async {
    try {
      final userId = int.tryParse(id);
      if (userId == null) {
        return Response(400, body: jsonEncode({'error': 'Invalid user ID'}));
      }

      final payload = request.context['user'] as Map<String, dynamic>?;
      final updaterId = payload?['userId'] as int?;

      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final email = data['email'] as String?;
      if (email != null) {
        final existingUser = await _db.getUserByEmail(email);
        if (existingUser != null && existingUser.id != userId) {
          return Response(400, body: jsonEncode({'error': 'Пользователь с таким email уже существует'}));
        }
      }

      final phone = data['phone'] as String?;
      if (phone != null && phone.isNotEmpty) {
        final existingUser = await _db.getUserByPhone(phone);
        if (existingUser != null && existingUser.id != userId) {
          return Response(400, body: jsonEncode({'error': 'Пользователь с таким телефоном уже существует'}));
        }
      }

      final dateOfBirthString = data['dateOfBirth'] as String?;
      final dateOfBirth = dateOfBirthString != null ? DateTime.parse(dateOfBirthString) : null;
      
      final archivedAtString = data['archivedAt'] as String?;
      final archivedAt = archivedAtString != null ? DateTime.parse(archivedAtString) : null;
      final archivedReason = data['archivedReason'] as String?; // Added archivedReason

      // Validation for archivedReason if archivedAt is not null
      if (archivedAt != null && (archivedReason == null || archivedReason.length < 5)) {
        return Response(400, body: jsonEncode({'error': 'Archived reason is required and must be at least 5 characters long when archiving a user.'}));
      }


      await _db.updateUser(
        userId,
        email: email,
        firstName: data['firstName'] as String?,
        lastName: data['lastName'] as String?,
        middleName: data['middleName'] as String?,
        phone: phone,
        gender: data['gender'] as String?,
        dateOfBirth: dateOfBirth,
        updatedBy: updaterId,
        archivedAt: archivedAt,
        archivedReason: archivedReason, // Passed archivedReason
      );

      // --- START OF NEW LOGIC ---
      // Check for client profile data and update it if present
      if (data.containsKey('client_profile') && data['client_profile'] is Map) {
        final clientProfileData = data['client_profile'] as Map<String, dynamic>;
        
        // Check if the user actually is a client
        final userRoles = await _db.getRolesForUser(userId);
        if (userRoles.any((role) => role.name == 'client')) {
            await _db.updateClientProfile(
              userId: userId,
              goalTrainingId: clientProfileData['goal_training_id'] as int?,
              levelTrainingId: clientProfileData['level_training_id'] as int?,
              trackCalories: clientProfileData['track_calories'] as bool?,
              coeffActivity: (clientProfileData['coeff_activity'] as num?)?.toDouble(),
              updatedBy: updaterId ?? userId,
            );
        }
      }
      // --- END OF NEW LOGIC ---

      final updatedUser = await _db.getUserById(userId);

      if (updatedUser == null) {
        return Response(404, body: jsonEncode({'error': 'User not found after update'}));
      }
      return Response.ok(jsonEncode({'user': updatedUser.toSafeJson()}));
    } catch (e) {
      print('Update user error: $e');
      return Response(500, body: jsonEncode({'error': 'Internal server error: $e'}));
    }
  }

  static Future<Response> deleteUser(Request request, String id) async {
    try {
      final userId = int.tryParse(id);
      if (userId == null) {
        return Response(400, body: jsonEncode({'error': 'Invalid user ID'}));
      }
      final success = await _db.deleteUser(userId);
      if (!success) {
        return Response(404, body: jsonEncode({'error': 'User not found'}));
      }
      return Response(200, body: jsonEncode({'message': 'User deleted successfully'}));
    } catch (e) {
      print('Delete user error: $e');
      return Response(500, body: jsonEncode({'error': 'Internal server error'}));
    }
  }

  static Future<Response> getProfile(Request request) async {
    try {
      final user = request.context['user'] as Map<String, dynamic>?;
      if (user == null) {
        return Response(401, body: jsonEncode({'error': 'Not authenticated'}));
      }
      final userId = user['userId'] as int;
      final userData = await _db.getUserById(userId);
      if (userData == null) {
        return Response(404, body: jsonEncode({'error': 'User not found'}));
      }
      return Response.ok(jsonEncode({'user': userData.toSafeJson()}));
    } catch (e) {
      print('Get profile error: $e');
      return Response(500, body: jsonEncode({'error': 'Internal server error'}));
    }
  }

  // --- МЕТОДЫ, ВОССТАНОВЛЕННЫЕ ПОСЛЕ СЛУЧАЙНОГО УДАЛЕНИЯ ---

  // Получить роли пользователя по ID
  static Future<Response> getUserRoles(Request request, String id) async {
    try {
      final userId = int.tryParse(id);
      if (userId == null) {
        return Response(400, body: jsonEncode({'error': 'Invalid user ID'}));
      }

      final user = await _db.getUserById(userId);
      if (user == null) {
        return Response(404, body: jsonEncode({'error': 'User not found'}));
      }

      return Response.ok(jsonEncode({'roles': user.roles.map((r) => r.toJson()).toList()}));
    } catch (e) {
      print('Get user roles error: $e');
      return Response(500, body: jsonEncode({'error': 'Internal server error'}));
    }
  }

  // Получить тренера для клиента
  static Future<Response> getTrainerForClient(Request request) async {
    try {
      final user = request.context['user'] as Map<String, dynamic>?;
      if (user == null) {
        return Response(401, body: jsonEncode({'error': 'Not authenticated'}));
      }

      final clientId = user['userId'] as int;
      final trainer = await _db.getTrainerForClient(clientId);

      if (trainer == null) {
        return Response(404, body: jsonEncode({'error': 'Trainer not found for this client'}));
      }

      return Response.ok(jsonEncode({'trainer': trainer.toSafeJson()}));
    } catch (e) {
      print('Get trainer for client error: $e');
      return Response(500, body: jsonEncode({'error': 'Internal server error'}));
    }
  }

  // Получить инструктора для клиента
  static Future<Response> getInstructorForClient(Request request) async {
    try {
      final user = request.context['user'] as Map<String, dynamic>?;
      if (user == null) {
        return Response(401, body: jsonEncode({'error': 'Not authenticated'}));
      }

      final clientId = user['userId'] as int;
      final instructor = await _db.getInstructorForClient(clientId);

      if (instructor == null) {
        return Response(404, body: jsonEncode({'error': 'Instructor not found for this client'}));
      }

      return Response.ok(jsonEncode({'instructor': instructor.toSafeJson()}));
    } catch (e) {
      print('Get instructor for client error: $e');
      return Response(500, body: jsonEncode({'error': 'Internal server error'}));
    }
  }

  // Получить менеджера для клиента
  static Future<Response> getManagerForClient(Request request) async {
    try {
      final user = request.context['user'] as Map<String, dynamic>?;
      if (user == null) {
        return Response(401, body: jsonEncode({'error': 'Not authenticated'}));
      }

      final clientId = user['userId'] as int;
      final manager = await _db.getManagerForClient(clientId);

      if (manager == null) {
        return Response(404, body: jsonEncode({'error': 'Manager not found for this client'}));
      }

      return Response.ok(jsonEncode({'manager': manager.toSafeJson()}));
    } catch (e) {
      print('Get manager for client error: $e');
      return Response(500, body: jsonEncode({'error': 'Internal server error'}));
    }
  }

  static Future<Response> getRoles(Request request) async {
    try {
      final roles = await _db.getAllRoles();
      final rolesJson = roles.map((role) => role.toJson()).toList();
      return Response.ok(jsonEncode({'roles': rolesJson}));
    } catch (e) {
      print('Get roles error: $e');
      return Response(500, body: jsonEncode({'error': 'Internal server error'}));
    }
  }

  static Future<Response> resetPassword(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final email = data['email'] as String?;
      final newPassword = data['newPassword'] as String?;

      if (email == null || newPassword == null) {
        return Response(400, body: jsonEncode({'error': 'Email and newPassword are required'}));
      }

      final user = await _db.getUserByEmail(email);
      if (user == null) {
        return Response(404, body: jsonEncode({'error': 'User not found'}));
      }

      final passwordHash = BCrypt.hashpw(newPassword, BCrypt.gensalt());

      await _db.updateUserPassword(user.id, passwordHash);

      return Response.ok(jsonEncode({'message': 'Password reset successfully'}));
    } catch (e) {
      print('Reset password error: $e');
      return Response(500, body: jsonEncode({'error': 'Internal server error'}));
    }
  }

  // Обновить профиль клиента (цель, уровень)
  static Future<Response> updateClientProfile(Request request) async {
    try {
      final payload = request.context['user'] as Map<String, dynamic>?;
      if (payload == null) {
        return Response.unauthorized(jsonEncode({'error': 'Not authenticated'}));
      }
      final userId = payload['userId'] as int;

      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final goalTrainingId = data['goal_training_id'] as int?;
      final levelTrainingId = data['level_training_id'] as int?;

      if (goalTrainingId == null && levelTrainingId == null) {
        return Response.badRequest(body: jsonEncode({'error': 'At least one field (goal_training_id or level_training_id) must be provided.'}));
      }

      await _db.updateClientProfile(
        userId: userId,
        goalTrainingId: goalTrainingId,
        levelTrainingId: levelTrainingId,
        updatedBy: userId,
      );

      final updatedUser = await _db.getUserById(userId);
      if (updatedUser == null) {
        return Response.notFound(jsonEncode({'error': 'User not found after update.'}));
      }

      return Response.ok(jsonEncode({
        'message': 'Профиль клиента успешно обновлен',
        'user': updatedUser.toSafeJson(),
      }));

    } catch (e) {
      print('Update client profile error: $e');
      return Response.internalServerError(body: jsonEncode({'error': 'Internal server error: $e'}));
    }
  }

  // Загрузить аватар пользователя
  static Future<Response> uploadAvatar(Request request, String id) async {
    try {
      final updater = request.context['user'] as Map<String, dynamic>?;
      if (updater == null) {
        return Response.unauthorized(jsonEncode({'error': 'Not authenticated'}));
      }
      final updaterId = updater['userId'] as int;

      final userId = int.tryParse(id);
      if (userId == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Invalid user ID'}));
      }

      String? fileName;
      List<int>? fileBytes;

      if (request.formData() case final form?) {
        await for (final formData in form.formData) {
          if (formData.name == 'photo') {
            fileName = formData.filename;
            fileBytes = await formData.part.readBytes();
          }
        }
      } else {
        return Response.badRequest(body: jsonEncode({'error': 'Not a multipart/form-data request'}));
      }

      if (fileName == null || fileBytes == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Missing photo file in form-data'}));
      }

      // Создаем директорию, если ее нет
      final uploadDir = Directory('C:/Android/PROJ/fitman_mvp2/uploads/avatars');
      if (!await uploadDir.exists()) {
        await uploadDir.create(recursive: true);
      }

      // Генерируем уникальное имя файла, чтобы избежать коллизий
      final extension = fileName.split('.').last;
      final uniqueFileName = 'user_${userId}_${DateTime.now().millisecondsSinceEpoch}.$extension';
      final filePath = '${uploadDir.path}/$uniqueFileName';
      
      final file = File(filePath);
      await file.writeAsBytes(fileBytes);

      // URL для доступа к файлу с клиента
      final photoUrl = '/uploads/avatars/$uniqueFileName';

      await _db.updateUserPhotoUrl(userId, photoUrl, updaterId);

      return Response.ok(jsonEncode({
        'message': 'Avatar uploaded successfully',
        'photoUrl': photoUrl,
      }));
    } catch (e, s) {
      print('Upload avatar error: $e');
      print(s);
      return Response.internalServerError(body: jsonEncode({'error': 'Internal server error'}));
    }
  }
}
