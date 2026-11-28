import 'dart:convert';

import 'package:fitman_backend/audit/audit_context.dart';
import 'package:fitman_backend/errors/app_exception.dart';
import 'package:fitman_backend/modules/users/services/user_service.dart';
import 'package:fitman_backend/modules/users/user_providers.dart';
import 'package:fitman_backend/security/access_policy.dart';
import 'package:fitman_common/fitman_common.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_multipart/shelf_multipart.dart';

/// HTTP-слой модуля пользователей и доступа.
///
/// Контроллер не содержит SQL и бизнес-правил: только разбор запроса,
/// актор, вызов сервиса и ответ.
class UsersController {
  UsersController({UserService? userService})
    : _userService = userService ?? UserProviders().userService;

  final UserService _userService;

  Future<Response> getUsers(Request request) {
    return _handle(() async {
      final query = request.url.queryParameters;
      final isArchived = query['isArchived'] == null
          ? null
          : query['isArchived'] == 'true';
      final users = await _userService.getUsers(
        isArchived: isArchived,
        role: query['role'],
      );
      return Response.ok(
        jsonEncode({'users': users.map((user) => user.toJson()).toList()}),
      );
    });
  }

  Future<Response> getUserById(Request request, String id) {
    return _handle(() async {
      final actor = _requireUser(request);
      _requireSelfOrStaff(actor, id);

      final user = await _userService.getById(id);
      if (user == null) {
        throw const NotFoundException('Пользователь не найден');
      }
      return Response.ok(jsonEncode({'user': user.toJson()}));
    });
  }

  Future<Response> createUser(Request request) {
    return _handle(() async {
      final actor = _requireUser(request);
      final data = await _readBody(request);

      final created = await _userService.createUser(
        _createInput(data),
        audit: AuditContext.fromRequest(request, user: actor),
      );

      return Response(
        201,
        body: jsonEncode({
          'message': 'Пользователь успешно создан',
          'user': created.toJson(),
        }),
        headers: const {'Content-Type': 'application/json'},
      );
    });
  }

  Future<Response> updateUser(Request request, String id) {
    return _handle(() async {
      final actor = _requireUser(request);
      _requireSelfOrStaff(actor, id);
      final data = await _readBody(request);
      final input = _updateInput(data);

      if (!_isStaff(actor) && input.archivedAtProvided) {
        throw const ForbiddenException('Архивация доступна сотрудникам');
      }

      final updated = await _userService.updateUser(
        id,
        input,
        audit: AuditContext.fromRequest(request, user: actor),
      );

      return Response.ok(jsonEncode({'user': updated.toJson()}));
    });
  }

  Future<Response> deleteUser(Request request, String id) {
    return _handle(() async {
      final actor = _requireUser(request);
      final data = await _readBody(request, allowEmpty: true);
      final reason =
          data['reason'] as String? ?? data['archivedReason'] as String?;

      await _userService.archiveUser(
        id,
        reason: reason,
        audit: AuditContext.fromRequest(request, user: actor),
      );

      return Response(204);
    });
  }

  Future<Response> restoreUser(Request request, String id) {
    return _handle(() async {
      final actor = _requireUser(request);

      await _userService.restoreUser(
        id,
        audit: AuditContext.fromRequest(request, user: actor),
      );

      return Response.ok(jsonEncode({'message': 'Пользователь восстановлен'}));
    });
  }

  Future<Response> getUserRoles(Request request, String id) {
    return _handle(() async {
      final user = await _userService.getById(id);
      if (user == null) {
        throw const NotFoundException('Пользователь не найден');
      }
      return Response.ok(
        jsonEncode({'roles': user.roles.map((role) => role.toJson()).toList()}),
      );
    });
  }

  Future<Response> updateUserRoles(Request request, String id) {
    return _handle(() async {
      final actor = _requireUser(request);
      final data = await _readBody(request);
      final roleNames = _stringList(data['roles'], 'roles');

      final updated = await _userService.updateRoles(
        id,
        roleNames,
        audit: AuditContext.fromRequest(request, user: actor),
      );

      return Response.ok(
        jsonEncode({
          'message': 'Роли пользователя успешно обновлены',
          'user': updated.toJson(),
        }),
      );
    });
  }

  Future<Response> getProfile(Request request) {
    return _handle(() async {
      final actor = _requireUser(request);
      final user = await _userService.getById(actor.id);
      if (user == null) {
        throw const NotFoundException('Пользователь не найден');
      }
      return Response.ok(jsonEncode({'user': user.toJson()}));
    });
  }

  Future<Response> getRoles(Request request) {
    return _handle(() async {
      final roles = await _userService.getAllRoles();
      return Response.ok(
        jsonEncode({'roles': roles.map((role) => role.toJson()).toList()}),
      );
    });
  }

  Future<Response> getMySettings(Request request) {
    return _handle(() async {
      final actor = _requireUser(request);
      final settings = await _userService.getSettings(actor.id);
      return Response.ok(jsonEncode({'settings': settings}));
    });
  }

  Future<Response> updateMySettings(Request request) {
    return _handle(() async {
      final actor = _requireUser(request);
      final data = await _readBody(request);
      final settings = await _userService.updateSettings(
        actor.id,
        sendNotifications: _optionalBool(data['sendNotifications']),
        hourNotification: _optionalInt(data['hourNotification']),
        audit: AuditContext.fromRequest(request, user: actor),
      );
      return Response.ok(jsonEncode({'settings': settings}));
    });
  }

  Future<Response> getUserSettings(Request request, String id) {
    return _handle(() async {
      final settings = await _userService.getSettings(id);
      return Response.ok(jsonEncode({'settings': settings}));
    });
  }

  Future<Response> updateUserSettings(Request request, String id) {
    return _handle(() async {
      final actor = _requireUser(request);
      final data = await _readBody(request);
      final settings = await _userService.updateSettings(
        id,
        sendNotifications: _optionalBool(data['sendNotifications']),
        hourNotification: _optionalInt(data['hourNotification']),
        audit: AuditContext.fromRequest(request, user: actor),
      );
      return Response.ok(jsonEncode({'settings': settings}));
    });
  }

  /// Сброс пароля администратором по id пользователя.
  Future<Response> resetPasswordForUser(Request request, String id) {
    return _handle(() async {
      final actor = _requireUser(request);
      final data = await _readBody(request);
      final password =
          data['password'] as String? ?? data['newPassword'] as String?;
      if (password == null || password.isEmpty) {
        throw const ValidationException('Укажите новый пароль');
      }

      await _userService.resetPassword(
        id,
        password,
        audit: AuditContext.fromRequest(request, user: actor),
      );

      return Response.ok(jsonEncode({'message': 'Пароль успешно изменён'}));
    });
  }

  /// Legacy-сброс пароля по email (совместимость со старым клиентом).
  Future<Response> resetPassword(Request request) {
    return _handle(() async {
      final actor = _requireUser(request);
      final data = await _readBody(request);
      final email = data['email'] as String?;
      final password =
          data['newPassword'] as String? ?? data['password'] as String?;

      if (email == null || password == null) {
        throw const ValidationException('Нужны email и новый пароль');
      }

      final user = await _userService.getByEmail(email);
      if (user == null) {
        throw const NotFoundException('Пользователь не найден');
      }

      await _userService.resetPassword(
        user.id,
        password,
        audit: AuditContext.fromRequest(request, user: actor),
      );

      return Response.ok(jsonEncode({'message': 'Пароль успешно изменён'}));
    });
  }

  Future<Response> updateClientProfile(Request request) {
    return _handle(() async {
      final actor = _requireUser(request);
      final data = await _readBody(request);

      final goalTrainingId = data['goal_training_id']?.toString();
      final levelTrainingId = data['level_training_id']?.toString();

      await _userService.updateClientProfile(
        userId: actor.id,
        goalTrainingId: goalTrainingId,
        levelTrainingId: levelTrainingId,
        audit: AuditContext.fromRequest(request, user: actor),
      );

      final updated = await _userService.getById(actor.id);
      if (updated == null) {
        throw const NotFoundException('Пользователь не найден');
      }

      return Response.ok(
        jsonEncode({
          'message': 'Профиль клиента успешно обновлен',
          'user': updated.toJson(),
        }),
      );
    });
  }

  Future<Response> uploadAvatar(Request request, String id) {
    return _handle(() async {
      final actor = _requireUser(request);
      _requireSelfOrStaff(actor, id);

      String? fileName;
      List<int>? fileBytes;

      if (request.formData() case final form?) {
        await for (final formData in form.formData) {
          if (formData.name == 'photo' && fileBytes == null) {
            fileName = formData.filename;
            fileBytes = await formData.part.readBytes();
          }
        }
      } else {
        throw const ValidationException(
          'Ожидается multipart/form-data с полем photo',
        );
      }

      if (fileName == null || fileBytes == null) {
        throw const ValidationException('В запросе нет файла photo');
      }

      final photoUrl = await _userService.uploadAvatar(
        userId: id,
        fileName: fileName,
        fileBytes: fileBytes,
        audit: AuditContext.fromRequest(request, user: actor),
      );

      return Response.ok(
        jsonEncode({
          'message': 'Аватар успешно загружен',
          'photoUrl': photoUrl,
        }),
      );
    });
  }

  Future<Response> getTrainerForClient(Request request) {
    return _relation(request, _userService.getTrainerForClient, 'trainer');
  }

  Future<Response> getInstructorForClient(Request request) {
    return _relation(
      request,
      _userService.getInstructorForClient,
      'instructor',
    );
  }

  Future<Response> getManagerForClient(Request request) {
    return _relation(request, _userService.getManagerForClient, 'manager');
  }

  Future<Response> getClientsForManager(Request request, String id) {
    return _listRelation(
      request,
      () => _userService.getClientsForManager(id),
      'clients',
    );
  }

  Future<Response> getInstructorsForManager(Request request, String id) {
    return _listRelation(
      request,
      () => _userService.getInstructorsForManager(id),
      'instructors',
    );
  }

  Future<Response> getTrainersForManager(Request request, String id) {
    return _listRelation(
      request,
      () => _userService.getTrainersForManager(id),
      'trainers',
    );
  }

  Future<Response> getClientsForInstructor(Request request, String id) {
    return _listRelation(
      request,
      () => _userService.getClientsForInstructor(id),
      'clients',
    );
  }

  Future<Response> getTrainersForInstructor(Request request, String id) {
    return _listRelation(
      request,
      () => _userService.getTrainersForInstructor(id),
      'trainers',
    );
  }

  Future<Response> getManagerForInstructor(Request request, String id) {
    return _handle(() async {
      final manager = await _userService.getManagerForInstructor(id);
      return Response.ok(jsonEncode({'manager': manager?.toJson()}));
    });
  }

  Future<Response> updateManagerClients(Request request, String id) {
    return _handle(() async {
      final data = await _readBody(request);
      await _userService.assignClientsToManager(
        id,
        _stringList(data['clientIds'], 'clientIds'),
      );
      return Response.ok(jsonEncode({'message': 'Клиенты назначены'}));
    });
  }

  Future<Response> updateManagerInstructors(Request request, String id) {
    return _handle(() async {
      final data = await _readBody(request);
      await _userService.assignInstructorsToManager(
        id,
        _stringList(data['instructorIds'], 'instructorIds'),
      );
      return Response.ok(jsonEncode({'message': 'Инструкторы назначены'}));
    });
  }

  Future<Response> updateManagerTrainers(Request request, String id) {
    return _handle(() async {
      final data = await _readBody(request);
      await _userService.assignTrainersToManager(
        id,
        _stringList(data['trainerIds'], 'trainerIds'),
      );
      return Response.ok(jsonEncode({'message': 'Тренеры назначены'}));
    });
  }

  Future<Response> _relation(
    Request request,
    Future<User?> Function(String) loader,
    String key,
  ) {
    return _handle(() async {
      final actor = _requireUser(request);
      final user = await loader(actor.id);
      if (user == null) {
        throw NotFoundException('$key не найден');
      }
      return Response.ok(jsonEncode({key: user.toJson()}));
    });
  }

  Future<Response> _listRelation(
    Request request,
    Future<List<User>> Function() loader,
    String key,
  ) {
    return _handle(() async {
      final users = await loader();
      return Response.ok(
        jsonEncode({key: users.map((user) => user.toJson()).toList()}),
      );
    });
  }

  Future<Response> _handle(Future<Response> Function() action) async {
    try {
      return await action();
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

  User _requireUser(Request request) {
    final user = request.context['user'] as User?;
    if (user == null) {
      throw const UnauthorizedException('Требуется авторизация');
    }
    return user;
  }

  /// Клиент может читать и менять только свой профиль.
  void _requireSelfOrStaff(User actor, String targetId) {
    if (!_isStaff(actor) && actor.id != targetId) {
      throw const ForbiddenException('Недостаточно прав');
    }
  }

  bool _isStaff(User actor) => AccessPolicy.isStaff(actor);

  Future<Map<String, dynamic>> _readBody(
    Request request, {
    bool allowEmpty = false,
  }) async {
    final raw = await request.readAsString();
    if (raw.trim().isEmpty) {
      if (allowEmpty) {
        return const {};
      }
      throw const ValidationException('Тело запроса обязательно');
    }
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const ValidationException('Ожидается JSON-объект');
    }
    return decoded;
  }

  CreateUserInput _createInput(Map<String, dynamic> data) {
    final password = data['password'] as String?;
    if (password == null || password.isEmpty) {
      throw const ValidationException('Пароль обязателен');
    }

    return CreateUserInput(
      email: _optionalString(data['email']),
      password: password,
      firstName: _requiredString(
        _value(data, 'firstName', 'first_name'),
        'firstName',
      ),
      lastName: _requiredString(
        _value(data, 'lastName', 'last_name'),
        'lastName',
      ),
      roles: _stringList(data['roles'], 'roles', fallback: const ['client']),
      middleName: _optionalString(_value(data, 'middleName', 'middle_name')),
      phone: _optionalString(data['phone']),
      gender: _optionalString(data['gender']),
      dateOfBirth: _optionalDate(_value(data, 'dateOfBirth', 'date_of_birth')),
      sendNotification:
          _optionalBool(
            _value(data, 'sendNotification', 'send_notification'),
          ) ??
          true,
      hourNotification:
          _optionalInt(_value(data, 'hourNotification', 'hour_notification')) ??
          2,
      clientProfile: _optionalMap(
        _value(data, 'clientProfile', 'client_profile'),
      ),
      employeeProfile: _optionalMap(
        _value(data, 'employeeProfile', 'employee_profile'),
      ),
    );
  }

  UpdateUserInput _updateInput(Map<String, dynamic> data) {
    final archivedAt = _optionalDate(_value(data, 'archivedAt', 'archived_at'));
    final settingsProvided =
        data.containsKey('sendNotification') ||
        data.containsKey('send_notification') ||
        data.containsKey('hourNotification') ||
        data.containsKey('hour_notification');

    return UpdateUserInput(
      email: _optionalString(data['email']),
      firstName: _optionalString(_value(data, 'firstName', 'first_name')),
      lastName: _optionalString(_value(data, 'lastName', 'last_name')),
      middleName: _optionalString(_value(data, 'middleName', 'middle_name')),
      phone: _optionalString(data['phone']),
      gender: _optionalString(data['gender']),
      dateOfBirth: _optionalDate(_value(data, 'dateOfBirth', 'date_of_birth')),
      // Клиент присылает "archived_at": null при обычном обновлении.
      // Архивацией считаем только непустую дату; восстановление — отдельный
      // endpoint, чтобы не разорять случайным null.
      archivedAtProvided: archivedAt != null,
      archivedAt: archivedAt,
      archivedReason: _optionalString(
        _value(data, 'archivedReason', 'archived_reason'),
      ),
      updateSettings: settingsProvided,
      sendNotification: _optionalBool(
        _value(data, 'sendNotification', 'send_notification'),
      ),
      hourNotification: _optionalInt(
        _value(data, 'hourNotification', 'hour_notification'),
      ),
      clientProfile: _optionalMap(
        _value(data, 'clientProfile', 'client_profile'),
      ),
      employeeProfile: _optionalMap(
        _value(data, 'employeeProfile', 'employee_profile'),
      ),
    );
  }

  Object? _value(Map<String, dynamic> data, String camel, String snake) {
    return data.containsKey(camel) ? data[camel] : data[snake];
  }

  String? _optionalString(Object? value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  String _requiredString(Object? value, String field) {
    final text = _optionalString(value);
    if (text == null) {
      throw ValidationException('Поле $field обязательно');
    }
    return text;
  }

  bool? _optionalBool(Object? value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is String) {
      if (value == 'true') return true;
      if (value == 'false') return false;
    }
    throw const ValidationException('Ожидается true или false');
  }

  int? _optionalInt(Object? value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    final parsed = int.tryParse(value.toString());
    if (parsed == null) {
      throw const ValidationException('Ожидается целое число');
    }
    return parsed;
  }

  DateTime? _optionalDate(Object? value) {
    if (value == null) return null;
    final parsed = DateTime.tryParse(value.toString());
    if (parsed == null) {
      throw const ValidationException('Неверный формат даты');
    }
    return parsed;
  }

  Map<String, dynamic>? _optionalMap(Object? value) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    throw const ValidationException('Ожидается JSON-объект');
  }

  List<String> _stringList(
    Object? value,
    String field, {
    List<String>? fallback,
  }) {
    if (value == null) {
      if (fallback != null) return fallback;
      throw ValidationException('Поле $field обязательно');
    }
    if (value is! List) {
      throw ValidationException('Поле $field должно быть списком');
    }
    return value.map((item) => item.toString()).toList();
  }
}
