import 'package:bcrypt/bcrypt.dart';
import 'package:fitman_common/fitman_common.dart';
import 'package:postgres/postgres.dart';

import '../../../audit/audit_context.dart';
import '../../../audit/audit_service.dart';
import '../../../config/database.dart';
import '../../../errors/app_exception.dart';
import '../../../logging/app_logger.dart';
import '../../../services/photo_service.dart';
import '../repositories/user_repository.dart';
import '../user_policy.dart';

/// Входные данные создания пользователя.
class CreateUserInput {
  const CreateUserInput({
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
    this.hourNotification = 2,
    this.clientProfile,
    this.employeeProfile,
  });

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
}

/// Входные данные обновления пользователя.
class UpdateUserInput {
  const UpdateUserInput({
    this.email,
    this.firstName,
    this.lastName,
    this.middleName,
    this.phone,
    this.gender,
    this.dateOfBirth,
    this.archivedAtProvided = false,
    this.archivedAt,
    this.archivedReason,
    this.updateSettings = false,
    this.sendNotification,
    this.hourNotification,
    this.clientProfile,
    this.employeeProfile,
  });

  final String? email;
  final String? firstName;
  final String? lastName;
  final String? middleName;
  final String? phone;
  final String? gender;
  final DateTime? dateOfBirth;
  final bool archivedAtProvided;
  final DateTime? archivedAt;
  final String? archivedReason;
  final bool updateSettings;
  final bool? sendNotification;
  final int? hourNotification;
  final Map<String, dynamic>? clientProfile;
  final Map<String, dynamic>? employeeProfile;
}

/// Прикладной сервис пользователей и доступа.
///
/// Владеет транзакцией write-path: изменение и запись аудита коммитятся
/// или откатываются вместе.
class UserService {
  UserService(this._repository, this._auditService, this._database);

  final UserRepository _repository;
  final AuditService _auditService;
  final Database _database;
  final PhotoService _photoService = PhotoService();

  Future<List<User>> getUsers({bool? isArchived, String? role}) {
    return _repository.getAllUsers(isArchived: isArchived, role: role);
  }

  Future<User?> getById(String id) => _repository.getUserById(id);

  Future<User?> getByEmail(String email) => _repository.getUserByEmail(email);

  Future<User?> getByIdentifier(String identifier) =>
      _repository.getUserByIdentifier(identifier);

  Future<List<Role>> getAllRoles() => _repository.getAllRoles();

  Future<List<Role>> getRolesForUser(String userId) {
    return _repository.getRolesForUser(userId);
  }

  Future<Map<String, dynamic>?> getSettings(String userId) {
    return _repository.getUserSettings(userId);
  }

  Future<User> createUser(
    CreateUserInput input, {
    required AuditContext audit,
  }) async {
    UserPolicy.validateCreate(
      email: input.email,
      phone: input.phone,
      password: input.password,
      roles: input.roles,
    );
    UserPolicy.normalizeNotificationHour(input.hourNotification);

    final passwordHash = BCrypt.hashpw(
      input.password,
      BCrypt.gensalt(logRounds: 12),
    );

    var effectiveAudit = audit;

    final created = await _database.runTx((session) async {
      await _ensureUniqueContact(
        email: input.email,
        phone: input.phone,
        session: session,
      );

      final now = DateTime.now();
      final user = User(
        id: '',
        email: input.email,
        passwordHash: passwordHash,
        firstName: input.firstName,
        lastName: input.lastName,
        middleName: input.middleName,
        roles: const [],
        phone: input.phone,
        gender: input.gender,
        dateOfBirth: input.dateOfBirth,
        sendNotification: input.sendNotification,
        hourNotification: input.hourNotification,
        createdAt: now,
        updatedAt: now,
      );

      final created = await _repository.createUser(
        user,
        input.roles,
        creatorId: audit.actorId,
        session: session,
      );

      // При самостоятельной регистрации актора ещё нет: фиксируем в аудите
      // самого созданного пользователя, а не пустого changed_by.
      if (audit.actorId == null) {
        effectiveAudit = AuditContext(
          actorId: created.id,
          actorRole: created.roles.map((role) => role.name).join(','),
          requestId: audit.requestId,
          source: audit.source,
        );
      }

      await _auditService.record(
        session: session,
        tableName: 'users',
        rowPk: created.id,
        action: 'INSERT',
        context: effectiveAudit,
        newValues: created.toJson(),
      );

      await _auditService.record(
        session: session,
        tableName: 'user_roles',
        rowPk: created.id,
        action: 'INSERT',
        context: effectiveAudit,
        newValues: {
          'user_id': created.id,
          'roles': created.roles.map((role) => role.name).toList(),
        },
      );

      await _auditService.record(
        session: session,
        tableName: 'user_settings',
        rowPk: created.id,
        action: 'INSERT',
        context: effectiveAudit,
        newValues: _settingsSnapshot(created),
      );

      await _applyProfiles(
        session: session,
        userId: created.id,
        clientProfile: input.clientProfile,
        employeeProfile: input.employeeProfile,
        audit: effectiveAudit,
        isCreate: true,
      );

      return created;
    });

    appLog.info(
      'Создан пользователь',
      fields: {
        'entity': 'users',
        'entity_id': created.id,
        'actor_id': effectiveAudit.actorId,
        'role': created.roles.map((role) => role.name).join(','),
        'request_id': audit.requestId,
      },
    );

    return created;
  }

  Future<User> updateUser(
    String id,
    UpdateUserInput input, {
    required AuditContext audit,
  }) async {
    UserPolicy.validateUpdate(
      email: input.email,
      phone: input.phone,
      archivedAtProvided: input.archivedAtProvided,
      archivedAt: input.archivedAt,
      archivedReason: input.archivedReason,
    );
    if (input.hourNotification != null) {
      UserPolicy.normalizeNotificationHour(input.hourNotification!);
    }

    final updated = await _database.runTx((session) async {
      final old = await _repository.getUserById(id, session: session);
      if (old == null) {
        throw const NotFoundException('Пользователь не найден');
      }

      if (input.email != null && input.email != old.email) {
        await _ensureUniqueContact(
          email: input.email,
          phone: null,
          session: session,
          excludeUserId: id,
        );
      }
      if (input.phone != null && input.phone != old.phone) {
        await _ensureUniqueContact(
          email: null,
          phone: input.phone,
          session: session,
          excludeUserId: id,
        );
      }

      final updated = await _repository.updateUser(
        id: id,
        email: input.email,
        firstName: input.firstName,
        lastName: input.lastName,
        middleName: input.middleName,
        phone: input.phone,
        gender: input.gender,
        dateOfBirth: input.dateOfBirth,
        updatedBy: audit.actorId,
        archivedAtProvided: input.archivedAtProvided,
        archivedAt: input.archivedAt,
        archivedReason: input.archivedReason,
        updateSettings: input.updateSettings,
        sendNotification: input.sendNotification,
        hourNotification: input.hourNotification,
        session: session,
      );
      if (updated == null) {
        throw const NotFoundException('Пользователь не найден');
      }

      final action = UserPolicy.actionFor(
        wasArchived: old.archivedAt != null,
        isArchived: updated.archivedAt != null,
      );

      await _auditService.record(
        session: session,
        tableName: 'users',
        rowPk: id,
        action: action,
        context: audit,
        oldValues: old.toJson(),
        newValues: updated.toJson(),
        reason: action == 'ARCHIVE' ? input.archivedReason : null,
      );

      if (input.updateSettings) {
        await _auditService.record(
          session: session,
          tableName: 'user_settings',
          rowPk: id,
          action: 'UPDATE',
          context: audit,
          oldValues: _settingsSnapshot(old),
          newValues: _settingsSnapshot(updated),
        );
      }

      await _applyProfiles(
        session: session,
        userId: id,
        clientProfile: input.clientProfile,
        employeeProfile: input.employeeProfile,
        audit: audit,
        oldUser: old,
        isCreate: false,
      );

      return updated;
    });

    appLog.info(
      'Обновлён пользователь',
      fields: {
        'entity': 'users',
        'entity_id': id,
        'actor_id': audit.actorId,
        'request_id': audit.requestId,
      },
    );

    return updated;
  }

  Future<User> updateRoles(
    String userId,
    List<String> roleNames, {
    required AuditContext audit,
  }) async {
    final updated = await _database.runTx((session) async {
      final old = await _repository.getUserById(userId, session: session);
      if (old == null) {
        throw const NotFoundException('Пользователь не найден');
      }

      final currentRoles = old.roles.map((role) => role.name).toList();
      UserPolicy.validateRoleChange(
        currentRoles: currentRoles,
        newRoles: roleNames,
      );

      final allRoles = await _repository.getAllRoles(session: session);
      final roleIds = <String>[];
      for (final name in roleNames) {
        String? roleId;
        for (final role in allRoles) {
          if (role.name == name) {
            roleId = role.id;
            break;
          }
        }
        if (roleId == null) {
          throw ValidationException('Неизвестная роль: $name');
        }
        roleIds.add(roleId);
      }

      await _repository.updateUserRoles(
        userId,
        roleIds,
        updatedBy: audit.actorId,
        session: session,
      );

      final updated = await _repository.getUserById(userId, session: session);
      if (updated == null) {
        throw const NotFoundException('Пользователь не найден');
      }

      await _auditService.record(
        session: session,
        tableName: 'user_roles',
        rowPk: userId,
        action: 'UPDATE',
        context: audit,
        oldValues: {'user_id': userId, 'roles': currentRoles},
        newValues: {
          'user_id': userId,
          'roles': updated.roles.map((role) => role.name).toList(),
        },
      );

      return updated;
    });

    appLog.info(
      'Изменены роли пользователя',
      fields: {
        'entity': 'user_roles',
        'entity_id': userId,
        'actor_id': audit.actorId,
        'role': updated.roles.map((role) => role.name).join(','),
        'request_id': audit.requestId,
      },
    );

    return updated;
  }

  Future<void> archiveUser(
    String userId, {
    String? reason,
    required AuditContext audit,
  }) async {
    final archiveReason = reason ?? 'Архивация пользователя';
    UserPolicy.validateUpdate(
      archivedAtProvided: true,
      archivedAt: DateTime.now(),
      archivedReason: archiveReason,
    );

    await _database.runTx((session) async {
      final old = await _repository.getUserById(userId, session: session);
      if (old == null) {
        throw const NotFoundException('Пользователь не найден');
      }
      if (old.archivedAt != null) {
        throw const ConflictException('Пользователь уже архивирован');
      }

      final archived = await _repository.archiveUser(
        id: userId,
        archivedBy: audit.actorId ?? userId,
        reason: archiveReason,
        session: session,
      );
      if (!archived) {
        throw const ConflictException('Пользователь уже архивирован');
      }

      final updated = await _repository.getUserById(userId, session: session);

      await _auditService.record(
        session: session,
        tableName: 'users',
        rowPk: userId,
        action: 'ARCHIVE',
        context: audit,
        oldValues: old.toJson(),
        newValues: updated?.toJson(),
        reason: archiveReason,
      );
    });

    appLog.info(
      'Пользователь архивирован',
      fields: {
        'entity': 'users',
        'entity_id': userId,
        'actor_id': audit.actorId,
        'request_id': audit.requestId,
      },
    );
  }

  Future<void> restoreUser(String userId, {required AuditContext audit}) async {
    await _database.runTx((session) async {
      final old = await _repository.getUserById(userId, session: session);
      if (old == null) {
        throw const NotFoundException('Пользователь не найден');
      }
      if (old.archivedAt == null) {
        throw const ConflictException('Пользователь не архивирован');
      }

      final updated = await _repository.updateUser(
        id: userId,
        updatedBy: audit.actorId,
        archivedAtProvided: true,
        archivedAt: null,
        session: session,
      );
      if (updated == null) {
        throw const NotFoundException('Пользователь не найден');
      }

      await _auditService.record(
        session: session,
        tableName: 'users',
        rowPk: userId,
        action: 'RESTORE',
        context: audit,
        oldValues: old.toJson(),
        newValues: updated.toJson(),
      );
    });

    appLog.info(
      'Пользователь восстановлен',
      fields: {
        'entity': 'users',
        'entity_id': userId,
        'actor_id': audit.actorId,
        'request_id': audit.requestId,
      },
    );
  }

  Future<void> resetPassword(
    String userId,
    String newPassword, {
    required AuditContext audit,
  }) async {
    UserPolicy.validatePassword(newPassword);
    final passwordHash = BCrypt.hashpw(
      newPassword,
      BCrypt.gensalt(logRounds: 12),
    );

    await _database.runTx((session) async {
      final old = await _repository.getUserById(userId, session: session);
      if (old == null) {
        throw const NotFoundException('Пользователь не найден');
      }

      await _repository.updateUserPassword(
        userId,
        passwordHash,
        updatedBy: audit.actorId,
        session: session,
      );

      final updated = await _repository.getUserById(userId, session: session);

      await _auditService.record(
        session: session,
        tableName: 'users',
        rowPk: userId,
        action: 'UPDATE',
        context: audit,
        oldValues: old.toJson(),
        newValues: updated?.toJson(),
        reason: 'password_reset',
      );
    });

    appLog.info(
      'Сброшен пароль пользователя',
      fields: {
        'entity': 'users',
        'entity_id': userId,
        'actor_id': audit.actorId,
        'request_id': audit.requestId,
      },
    );
  }

  Future<Map<String, dynamic>> updateSettings(
    String userId, {
    bool? sendNotifications,
    int? hourNotification,
    required AuditContext audit,
  }) async {
    if (hourNotification != null) {
      UserPolicy.normalizeNotificationHour(hourNotification);
    }

    final settings = await _database.runTx((session) async {
      final old = await _repository.getUserById(userId, session: session);
      if (old == null) {
        throw const NotFoundException('Пользователь не найден');
      }
      final oldSettings = await _repository.getUserSettings(
        userId,
        session: session,
      );

      await _repository.upsertUserSettings(
        userId: userId,
        sendNotifications: sendNotifications,
        hourNotification: hourNotification,
        updatedBy: audit.actorId ?? userId,
        session: session,
      );

      final newSettings = await _repository.getUserSettings(
        userId,
        session: session,
      );
      final newValues = newSettings ?? const <String, dynamic>{};

      await _auditService.record(
        session: session,
        tableName: 'user_settings',
        rowPk: userId,
        action: oldSettings == null ? 'INSERT' : 'UPDATE',
        context: audit,
        oldValues: oldSettings,
        newValues: newValues,
      );

      return newValues;
    });

    appLog.info(
      'Обновлены настройки пользователя',
      fields: {
        'entity': 'user_settings',
        'entity_id': userId,
        'actor_id': audit.actorId,
        'request_id': audit.requestId,
      },
    );

    return settings;
  }

  Future<void> updateClientProfile({
    required String userId,
    String? goalTrainingId,
    String? levelTrainingId,
    required AuditContext audit,
  }) async {
    if (goalTrainingId == null && levelTrainingId == null) {
      throw const ValidationException(
        'Укажите goal_training_id или level_training_id',
      );
    }

    await _database.runTx((session) async {
      final old = await _repository.getUserById(userId, session: session);
      if (old == null) {
        throw const NotFoundException('Пользователь не найден');
      }

      await _repository.updateClientProfile(
        userId: userId,
        goalTrainingId: goalTrainingId,
        levelTrainingId: levelTrainingId,
        updatedBy: audit.actorId ?? userId,
        session: session,
      );

      final updated = await _repository.getUserById(userId, session: session);

      await _auditService.record(
        session: session,
        tableName: 'client_profiles',
        rowPk: userId,
        action: 'UPDATE',
        context: audit,
        oldValues: old.clientProfile?.toJson(),
        newValues: updated?.clientProfile?.toJson(),
      );
    });

    appLog.info(
      'Обновлён профиль клиента',
      fields: {
        'entity': 'client_profiles',
        'entity_id': userId,
        'actor_id': audit.actorId,
        'request_id': audit.requestId,
      },
    );
  }

  Future<String> uploadAvatar({
    required String userId,
    required String fileName,
    required List<int> fileBytes,
    required AuditContext audit,
  }) async {
    final publicUrl = await _photoService.savePhoto(
      subDirectory: 'avatars',
      fileName: fileName,
      fileBytes: fileBytes,
    );

    try {
      await _database.runTx((session) async {
        final old = await _repository.getUserById(userId, session: session);
        if (old == null) {
          throw const NotFoundException('Пользователь не найден');
        }

        await _repository.updateUserPhotoUrl(
          userId,
          publicUrl,
          audit.actorId ?? userId,
          session: session,
        );

        final updated = await _repository.getUserById(userId, session: session);

        await _auditService.record(
          session: session,
          tableName: 'users',
          rowPk: userId,
          action: 'UPDATE',
          context: audit,
          oldValues: old.toJson(),
          newValues: updated?.toJson(),
        );
      });
    } catch (_) {
      await _photoService.deletePhotoFile(publicUrl);
      rethrow;
    }

    appLog.info(
      'Загружен аватар пользователя',
      fields: {
        'entity': 'users',
        'entity_id': userId,
        'actor_id': audit.actorId,
        'request_id': audit.requestId,
      },
    );

    return publicUrl;
  }

  Future<T> _runRead<T>(Future<T> Function() action) => action();

  Future<void> _applyProfiles({
    required Session session,
    required String userId,
    required Map<String, dynamic>? clientProfile,
    required Map<String, dynamic>? employeeProfile,
    required AuditContext audit,
    required bool isCreate,
    User? oldUser,
  }) async {
    if (clientProfile != null) {
      await _repository.updateClientProfile(
        userId: userId,
        goalTrainingId: clientProfile['goal_training_id']?.toString(),
        levelTrainingId: clientProfile['level_training_id']?.toString(),
        trackCalories: clientProfile['track_calories'] as bool?,
        coeffActivity: (clientProfile['coeff_activity'] as num?)?.toDouble(),
        updatedBy: audit.actorId ?? userId,
        session: session,
      );

      final updated = await _repository.getUserById(userId, session: session);
      await _auditService.record(
        session: session,
        tableName: 'client_profiles',
        rowPk: userId,
        action: isCreate ? 'INSERT' : 'UPDATE',
        context: audit,
        oldValues: oldUser?.clientProfile?.toJson(),
        newValues: updated?.clientProfile?.toJson(),
      );
    }

    if (employeeProfile != null) {
      await _repository.updateEmployeeProfile(
        userId: userId,
        specialization: employeeProfile['specialization'] as String?,
        workExperience: employeeProfile['work_experience'] as int?,
        canMaintainEquipment:
            employeeProfile['can_maintain_equipment'] as bool?,
        updatedBy: audit.actorId ?? userId,
        session: session,
      );

      final updated = await _repository.getUserById(userId, session: session);
      await _auditService.record(
        session: session,
        tableName: 'employee_profiles',
        rowPk: userId,
        action: isCreate ? 'INSERT' : 'UPDATE',
        context: audit,
        oldValues: oldUser?.employeeProfile?.toJson(),
        newValues: updated?.employeeProfile?.toJson(),
      );
    }
  }

  Future<void> _ensureUniqueContact({
    required String? email,
    required String? phone,
    required Session session,
    String? excludeUserId,
  }) async {
    if (email != null && email.isNotEmpty) {
      final existing = await _repository.getUserByEmail(
        email,
        session: session,
      );
      if (existing != null && existing.id != excludeUserId) {
        throw const ConflictException(
          'Пользователь с таким email уже существует',
        );
      }
    }
    if (phone != null && phone.isNotEmpty) {
      final existing = await _repository.getUserByPhone(
        phone,
        session: session,
      );
      if (existing != null && existing.id != excludeUserId) {
        throw const ConflictException(
          'Пользователь с таким телефоном уже существует',
        );
      }
    }
  }

  Map<String, Object?> _settingsSnapshot(User user) {
    return {
      'user_id': user.id,
      'send_notifications': user.sendNotification,
      'hour_notification': user.hourNotification,
    };
  }

  // --- Чтение связей (без изменений) ---

  Future<List<User>> getClientsForManager(String managerId) {
    return _runRead(() => _repository.getClientsForManager(managerId));
  }

  Future<List<User>> getInstructorsForManager(String managerId) {
    return _runRead(() => _repository.getInstructorsForManager(managerId));
  }

  Future<List<User>> getTrainersForManager(String managerId) {
    return _runRead(() => _repository.getTrainersForManager(managerId));
  }

  Future<List<User>> getClientsForInstructor(String instructorId) {
    return _runRead(() => _repository.getClientsForInstructor(instructorId));
  }

  Future<List<User>> getTrainersForInstructor(String instructorId) {
    return _runRead(() => _repository.getTrainersForInstructor(instructorId));
  }

  Future<User?> getManagerForInstructor(String instructorId) {
    return _runRead(() => _repository.getManagerForInstructor(instructorId));
  }

  Future<User?> getTrainerForClient(String clientId) {
    return _runRead(() => _repository.getTrainerForClient(clientId));
  }

  Future<User?> getInstructorForClient(String clientId) {
    return _runRead(() => _repository.getInstructorForClient(clientId));
  }

  Future<User?> getManagerForClient(String clientId) {
    return _runRead(() => _repository.getManagerForClient(clientId));
  }

  // --- Связи менеджера (запись оставлена без аудита до сессии групп) ---

  Future<void> assignClientsToManager(String managerId, List<String> ids) {
    return _repository.assignClientsToManager(managerId, ids);
  }

  Future<void> assignInstructorsToManager(String managerId, List<String> ids) {
    return _repository.assignInstructorsToManager(managerId, ids);
  }

  Future<void> assignTrainersToManager(String managerId, List<String> ids) {
    return _repository.assignTrainersToManager(managerId, ids);
  }

  Future<List<String>> getAssignedClientIds(String managerId) {
    return _repository.getAssignedClientIds(managerId);
  }

  Future<List<String>> getAssignedInstructorIds(String managerId) {
    return _repository.getAssignedInstructorIds(managerId);
  }

  Future<List<String>> getAssignedTrainerIds(String managerId) {
    return _repository.getAssignedTrainerIds(managerId);
  }
}
