import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import '../config/database.dart';
import '../config/app_config.dart';
import '../errors/app_exception.dart';
import '../logging/app_logger.dart';
import '../middleware/request_context.dart';
import 'package:fitman_common/fitman_common.dart';

class AuthController {
  static Future<Response> login(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final phone = data['phone'] as String;
      final password = data['password'] as String;

      // TODO: Add more robust phone number validation
      if (phone.isEmpty) {
        return Response(
          400,
          body: jsonEncode({'error': 'Phone number cannot be empty'}),
        );
      }

      if (password.isEmpty) {
        return Response(
          401,
          body: jsonEncode({'error': 'Invalid credentials'}),
        );
      }

      final user = await Database().users.getUserByPhone(phone);

      if (user == null) {
        appLog.info(
          'Неудачная попытка входа',
          fields: {'request_id': RequestContext.requestIdOf(request)},
        );
        return Response(
          401,
          body: jsonEncode({'error': 'Invalid credentials'}),
        );
      }

      final isValidPassword = BCrypt.checkpw(password, user.passwordHash);

      if (!isValidPassword) {
        appLog.info(
          'Неудачная попытка входа',
          fields: {
            'user_id': user.id,
            'request_id': RequestContext.requestIdOf(request),
          },
        );
        return Response(
          401,
          body: jsonEncode({'error': 'Invalid credentials'}),
        );
      }

      final token = _generateJwtToken(user);
      final response = {
        'token': token,
        'user': user.toJson(),
      };

      appLog.info(
        'Вход выполнен',
        fields: {
          'user_id': user.id,
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

      final email = data['email'] as String;
      final password = data['password'] as String;
      final firstName = data['firstName'] as String;
      final lastName = data['lastName'] as String;
      final roles = (data['roles'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          ['client'];

      // Валидация данных
      if (!AppConfig.isValidEmail(email)) {
        return Response(
          400,
          body: jsonEncode({'error': 'Invalid email format'}),
        );
      }

      if (!AppConfig.isValidPassword(password)) {
        return Response(
          400,
          body: jsonEncode({
            'error':
                'Password must be at least ${AppConfig.minPasswordLength} characters',
          }),
        );
      }

      // Validate each role
      for (final roleName in roles) {
        if (!AppConfig.isValidRole(roleName)) {
          return Response(
            400,
            body: jsonEncode({
              'error':
                  'Invalid role: $roleName. Allowed roles: ${AppConfig.allowedRoles.join(', ')}',
            }),
          );
        }
      }

      final existingUser = await Database().users.getUserByEmail(email);
      if (existingUser != null) {
        return Response(
          400,
          body: jsonEncode({'error': 'User already exists'}),
        );
      }

      final passwordHash = BCrypt.hashpw(password, BCrypt.gensalt());

      final newUser = User(
        id: '',
        email: email,
        passwordHash: passwordHash,
        firstName: firstName,
        lastName: lastName,
        roles: [],
        phone: data['phone'] as String?,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final createdUser = await Database().users.createUser(newUser, roles);
      final token = _generateJwtToken(createdUser);

      final response = {
        'token': token,
        'user': createdUser.toJson(),
      };

      appLog.info(
        'Пользователь зарегистрирован',
        fields: {
          'user_id': createdUser.id,
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

  static String _generateJwtToken(User user) {
    final jwt = JWT({
      'userId': user.id,
      'email': user.email,
      'roles': user.roles.map((r) => r.name).toList(),
      'firstName': user.firstName,
      'lastName': user.lastName,
      'exp': (DateTime.now()
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
        return Response(
          401,
          body: jsonEncode({'error': 'Not authenticated'}),
        );
      }

      return Response.ok(jsonEncode({
        'authenticated': true,
        'user': user.toJson(),
      }));
    } on AppException {
      rethrow;
    } catch (error, stackTrace) {
      throw InternalException(cause: error, stackTrace: stackTrace);
    }
  }
}
