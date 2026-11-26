import 'dart:convert';

import 'package:bcrypt/bcrypt.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:fitman_backend/audit/audit_context.dart';
import 'package:fitman_backend/config/app_config.dart';
import 'package:fitman_backend/errors/app_exception.dart';
import 'package:fitman_backend/logging/app_logger.dart';
import 'package:fitman_backend/middleware/request_context.dart';
import 'package:fitman_backend/modules/users/services/user_service.dart';
import 'package:fitman_backend/modules/users/user_providers.dart';
import 'package:fitman_common/fitman_common.dart';
import 'package:shelf/shelf.dart';

class AuthController {
  static UserService get _users => UserProviders().userService;

  static Future<Response> login(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      // Вход по одному идентификатору: телефон или email.
      // `phone` поддерживается для совместимости со старыми клиентами.
      final identifier =
          (data['identifier'] ?? data['phone'])?.toString().trim() ?? '';
      final password = data['password'] as String;

      if (identifier.isEmpty) {
        throw const ValidationException('Введите телефон или email');
      }
      if (password.isEmpty) {
        throw const UnauthorizedException('Неверные учётные данные');
      }

      final user = await _users.getByIdentifier(identifier);

      if (user == null) {
        appLog.info(
          'Неудачная попытка входа',
          fields: {'request_id': RequestContext.requestIdOf(request)},
        );
        throw const UnauthorizedException('Неверные учётные данные');
      }

      if (user.archivedAt != null) {
        appLog.info(
          'Попытка входа в архивную учётную запись',
          fields: {
            'user_id': user.id,
            'request_id': RequestContext.requestIdOf(request),
          },
        );
        throw const UnauthorizedException('Учётная запись архивирована');
      }

      if (!_isPasswordValid(password, user.passwordHash)) {
        appLog.info(
          'Неудачная попытка входа',
          fields: {
            'user_id': user.id,
            'request_id': RequestContext.requestIdOf(request),
          },
        );
        throw const UnauthorizedException('Неверные учётные данные');
      }

      final token = _generateJwtToken(user);
      final response = {'token': token, 'user': user.toJson()};

      appLog.info(
        'Вход выполнен',
        fields: {
          'user_id': user.id,
          'role': user.roles.map((role) => role.name).join(','),
          'request_id': RequestContext.requestIdOf(request),
        },
      );
      return Response.ok(jsonEncode(response));
    } on AppException {
      rethrow;
    } on FormatException {
      throw const ValidationException('Некорректный формат запроса');
    } on TypeError {
      throw const ValidationException('Некорректный формат запроса');
    } catch (error, stackTrace) {
      throw InternalException(cause: error, stackTrace: stackTrace);
    }
  }

  static Future<Response> register(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final phone = data['phone']?.toString().trim();
      final email = data['email']?.toString().trim();
      final password = data['password'] as String?;
      final firstName = data['firstName'] as String?;
      final lastName = data['lastName'] as String?;

      if (password == null || firstName == null || lastName == null) {
        throw const ValidationException('Нужны телефон, пароль, имя и фамилия');
      }
      if (phone == null || phone.isEmpty) {
        throw const ValidationException('Телефон обязателен');
      }

      // Самостоятельная регистрация из ТЗ — только клиент. Роли сотрудников
      // назначает администратор.
      final requestedRoles =
          (data['roles'] as List<dynamic>?)
              ?.map((role) => role.toString())
              .toList() ??
          const ['client'];
      if (requestedRoles.any((role) => role != 'client')) {
        throw const ValidationException(
          'Самостоятельная регистрация доступна только клиентам',
        );
      }

      final createdUser = await _users.createUser(
        CreateUserInput(
          email: email,
          password: password,
          firstName: firstName,
          lastName: lastName,
          roles: const ['client'],
          phone: phone,
          gender: data['gender'] as String?,
          dateOfBirth: data['dateOfBirth'] == null
              ? null
              : DateTime.tryParse(data['dateOfBirth'].toString()),
        ),
        audit: AuditContext.fromRequest(request, user: null),
      );

      final token = _generateJwtToken(createdUser);
      final response = {'token': token, 'user': createdUser.toJson()};

      appLog.info(
        'Пользователь зарегистрирован',
        fields: {
          'user_id': createdUser.id,
          'role': createdUser.roles.map((role) => role.name).join(','),
          'request_id': RequestContext.requestIdOf(request),
        },
      );
      return Response(201, body: jsonEncode(response));
    } on AppException {
      rethrow;
    } on FormatException {
      throw const ValidationException('Некорректный формат запроса');
    } on TypeError {
      throw const ValidationException('Некорректный формат запроса');
    } catch (error, stackTrace) {
      throw InternalException(cause: error, stackTrace: stackTrace);
    }
  }

  static bool _isPasswordValid(String password, String passwordHash) {
    // Пустой хеш у импортированных/тестовых записей: вход запрещён,
    // а не пропускается.
    if (passwordHash.isEmpty) {
      return false;
    }
    try {
      return BCrypt.checkpw(password, passwordHash);
    } catch (_) {
      return false;
    }
  }

  static String _generateJwtToken(User user) {
    final jwt = JWT({
      'userId': user.id,
      'email': user.email,
      'roles': user.roles.map((r) => r.name).toList(),
      'firstName': user.firstName,
      'lastName': user.lastName,
      'exp':
          (DateTime.now()
                      .add(Duration(hours: AppConfig.instance.jwtExpiryHours))
                      .millisecondsSinceEpoch /
                  1000)
              .round(),
    });

    return jwt.sign(SecretKey(AppConfig.instance.jwtSecret));
  }

  static Map<String, dynamic>? verifyToken(String token) {
    try {
      final jwt = JWT.verify(token, SecretKey(AppConfig.instance.jwtSecret));
      return jwt.payload;
    } catch (e) {
      return null;
    }
  }

  static Future<Response> checkAuth(Request request) async {
    try {
      final user = request.context['user'] as User?;
      if (user == null) {
        throw const UnauthorizedException('Требуется авторизация');
      }

      return Response.ok(
        jsonEncode({'authenticated': true, 'user': user.toJson()}),
      );
    } on AppException {
      rethrow;
    } catch (error, stackTrace) {
      throw InternalException(cause: error, stackTrace: stackTrace);
    }
  }
}
