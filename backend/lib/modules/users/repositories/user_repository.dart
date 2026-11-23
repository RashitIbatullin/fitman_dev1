import 'package:postgres/postgres.dart';

import '../../../config/database.dart';
import 'package:fitman_common/fitman_common.dart';
import 'package:fitman_backend/logging/app_logger.dart';

abstract class UserRepository {
  Future<List<Role>> getAllRoles({Session? session});
  Future<Role?> getRoleByName(String roleName, {Session? session});
  Future<List<Role>> getRolesForUser(String userId, {Session? session});
  Future<List<User>> getAllUsers({
    bool? isArchived,
    String? role,
    Session? session,
  });
  Future<User?> getUserByEmail(String email, {Session? session});
  Future<User?> getUserByPhone(String phone, {Session? session});
  Future<User?> getUserById(String id, {Session? session});
  Future<User> createUser(
    User user,
    List<String> roleNames, {
    String? creatorId,
    Session? session,
  });
  Future<void> updateUserRoles(
    String userId,
    List<String> newRoleIds, {
    String? updatedBy,
    Session? session,
  });
  Future<User?> updateUser({
    required String id,
    String? email,
    String? firstName,
    String? lastName,
    String? middleName,
    String? phone,
    String? gender,
    DateTime? dateOfBirth,
    String? updatedBy,
    bool archivedAtProvided = false,
    DateTime? archivedAt,
    String? archivedReason,
    bool updateSettings = false,
    bool? sendNotification,
    int? hourNotification,
    Session? session,
  });
  Future<void> updateClientProfile({
    required String userId,
    String? goalTrainingId,
    String? levelTrainingId,
    bool? trackCalories,
    double? coeffActivity,
    required String updatedBy,
    Session? session,
  });
  Future<void> updateEmployeeProfile({
    required String userId,
    String? specialization,
    int? workExperience,
    bool? canMaintainEquipment,
    required String updatedBy,
    Session? session,
  });
  Future<bool> archiveUser({
    required String id,
    required String archivedBy,
    String? reason,
    Session? session,
  });
  Future<void> updateUserPassword(
    String userId,
    String newPasswordHash, {
    String? updatedBy,
    Session? session,
  });
  Future<void> updateUserPhotoUrl(
    String userId,
    String photoUrl,
    String updaterId, {
    Session? session,
  });
  Future<Map<String, dynamic>?> getUserSettings(
    String userId, {
    Session? session,
  });
  Future<void> upsertUserSettings({
    required String userId,
    bool? sendNotifications,
    int? hourNotification,
    required String updatedBy,
    Session? session,
  });

  // Manager/Client/Instructor relationships
  Future<List<User>> getClientsForManager(String managerId);
  Future<void> assignClientsToManager(String managerId, List<String> clientIds);
  Future<List<String>> getAssignedClientIds(String managerId);
  Future<List<User>> getInstructorsForManager(String managerId);
  Future<void> assignInstructorsToManager(
    String managerId,
    List<String> instructorIds,
  );
  Future<List<String>> getAssignedInstructorIds(String managerId);
  Future<List<User>> getTrainersForManager(String managerId);
  Future<void> assignTrainersToManager(
    String managerId,
    List<String> trainerIds,
  );
  Future<List<String>> getAssignedTrainerIds(String managerId);
  Future<List<User>> getClientsForInstructor(String instructorId);
  Future<List<User>> getTrainersForInstructor(String instructorId);
  Future<User?> getManagerForInstructor(String instructorId);
  Future<User?> getTrainerForClient(String clientId);
  Future<User?> getInstructorForClient(String clientId);
  Future<User?> getManagerForClient(String clientId);
}

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this._db);

  final Database _db;

  Future<Connection> get _connection => _db.connection;

  /// Выполняет действие в переданной транзакции.
  ///
  /// Если сессия не передана, репозиторий открывает собственную транзакцию —
  /// так работают legacy-вызовы. Сервис всегда передаёт сессию.
  Future<T> _withSession<T>(
    Session? session,
    Future<T> Function(Session connection) action,
  ) async {
    if (session != null) {
      return action(session);
    }
    final conn = await _connection;
    return conn.runTx(action);
  }

  @override
  Future<List<Role>> getAllRoles({Session? session}) async {
    try {
      final conn = session ?? await _connection;
      final results = await conn.execute('''
        SELECT id, name, title, icon FROM roles
      ''');
      return results.map((row) => Role.fromMap(row.toColumnMap())).toList();
    } catch (e) {
      appLog.error('❌ getAllRoles error: $e');
      rethrow;
    }
  }

  @override
  Future<Role?> getRoleByName(String roleName, {Session? session}) async {
    try {
      final conn = session ?? await _connection;
      final results = await conn.execute(
        Sql.named(
          'SELECT id, name, title, icon FROM roles WHERE name = @roleName',
        ),
        parameters: {'roleName': roleName},
      );
      if (results.isEmpty) return null;
      return Role.fromMap(results.first.toColumnMap());
    } catch (e) {
      appLog.error('❌ getRoleByName error: $e');
      rethrow;
    }
  }

  @override
  Future<List<Role>> getRolesForUser(String userId, {Session? session}) async {
    try {
      final conn = session ?? await _connection;
      final results = await conn.execute(
        Sql.named('''
          SELECT r.id, r.name, r.title, r.icon
          FROM roles r
          INNER JOIN user_roles ur ON r.id = ur.role_id
          WHERE ur.user_id = @userId
          ORDER BY r.name
        '''),
        parameters: {'userId': userId},
      );
      return results.map((row) => Role.fromMap(row.toColumnMap())).toList();
    } catch (e) {
      appLog.error('❌ getRolesForUser error: $e');
      rethrow;
    }
  }

  @override
  Future<List<User>> getAllUsers({
    bool? isArchived,
    String? role,
    Session? session,
  }) async {
    try {
      final conn = session ?? await _connection;

      final whereClauses = <String>[];
      final parameters = <String, dynamic>{};

      if (isArchived != null) {
        whereClauses.add(
          isArchived ? 'u.archived_at IS NOT NULL' : 'u.archived_at IS NULL',
        );
      }
      if (role != null && role != 'all') {
        whereClauses.add('''
          EXISTS (
            SELECT 1
            FROM user_roles ur
            INNER JOIN roles r ON ur.role_id = r.id
            WHERE ur.user_id = u.id AND r.name = @roleName
          )
        ''');
        parameters['roleName'] = role;
      }

      final whereString = whereClauses.isNotEmpty
          ? 'WHERE ${whereClauses.join(' AND ')}'
          : '';

      final query =
          '''
        SELECT
          u.id, u.login, u.email, u.password_hash, u.first_name, u.last_name,
          u.middle_name, u.phone, u.gender, u.date_of_birth, u.photo_url,
          u.created_at, u.updated_at, u.archived_at, u.archived_by,
          u.archived_reason,
          COALESCE(us.send_notifications, true) AS send_notification,
          COALESCE(us.hour_notification, 2) AS hour_notification,
          COALESCE(us.notification_email, true) AS notification_email,
          COALESCE(us.notification_push, true) AS notification_push,
          cp.user_id AS cp_user_id, cp.goal_training_id,
          cp.level_training_id, cp.track_calories, cp.coeff_activity,
          ep.user_id AS ep_user_id, ep.specialization, ep.work_experience,
          ep.can_maintain_equipment,
          ip.user_id AS ip_user_id, ip.is_duty AS ip_is_duty,
          ip.can_replace_trainer, ip.can_create_plan,
          tp.user_id AS tp_user_id,
          mp.user_id AS mp_user_id, mp.is_duty AS mp_is_duty
        FROM users u
        LEFT JOIN user_settings us ON u.id = us.user_id
        LEFT JOIN client_profiles cp ON u.id = cp.user_id
        LEFT JOIN employee_profiles ep ON u.id = ep.user_id
        LEFT JOIN instructor_profiles ip ON u.id = ip.user_id
        LEFT JOIN trainer_profiles tp ON u.id = tp.user_id
        LEFT JOIN manager_profiles mp ON u.id = mp.user_id
        $whereString
        ORDER BY u.last_name, u.first_name
      ''';

      final results = await conn.execute(
        Sql.named(query),
        parameters: parameters,
      );

      final users = <User>[];
      for (final row in results) {
        final userMap = row.toColumnMap();
        final user = _userWithProfiles(userMap);
        users.add(
          user.copyWith(roles: await getRolesForUser(user.id, session: conn)),
        );
      }
      return users;
    } catch (e) {
      appLog.error('❌ getAllUsers error: $e');
      rethrow;
    }
  }

  @override
  Future<User?> getUserByEmail(String email, {Session? session}) async {
    return _getSingle(
      'WHERE u.email = @value',
      email,
      session: session,
      logLabel: 'getUserByEmail',
    );
  }

  @override
  Future<User?> getUserByPhone(String phone, {Session? session}) async {
    return _getSingle(
      'WHERE u.phone = @value',
      phone,
      session: session,
      logLabel: 'getUserByPhone',
    );
  }

  @override
  Future<User?> getUserById(String id, {Session? session}) async {
    return _getSingle(
      'WHERE u.id = @value',
      id,
      session: session,
      logLabel: 'getUserById',
    );
  }

  Future<User?> _getSingle(
    String whereClause,
    String value, {
    required String logLabel,
    Session? session,
  }) async {
    try {
      final conn = session ?? await _connection;
      final results = await conn.execute(
        Sql.named('''
          SELECT
            u.id, u.login, u.email, u.password_hash, u.first_name, u.last_name,
            u.middle_name, u.phone, u.gender, u.date_of_birth, u.photo_url,
            u.created_at, u.updated_at, u.archived_at, u.archived_by,
            u.archived_reason,
            COALESCE(us.send_notifications, true) AS send_notification,
            COALESCE(us.hour_notification, 2) AS hour_notification,
            COALESCE(us.notification_email, true) AS notification_email,
            COALESCE(us.notification_push, true) AS notification_push
          FROM users u
          LEFT JOIN user_settings us ON u.id = us.user_id
          $whereClause
          LIMIT 1
        '''),
        parameters: {'value': value},
      );

      if (results.isEmpty) return null;

      final user = User.fromMap(results.first.toColumnMap());
      final roles = await getRolesForUser(user.id, session: conn);
      return _fetchAndAttachProfiles(user.copyWith(roles: roles), conn);
    } catch (e) {
      appLog.error('❌ $logLabel error: $e');
      rethrow;
    }
  }

  User _userWithProfiles(Map<String, dynamic> userMap) {
    ClientProfile? clientProfile;
    if (userMap['cp_user_id'] != null) {
      clientProfile = ClientProfile.fromMap({
        'user_id': userMap['cp_user_id'],
        'goal_training_id': userMap['goal_training_id'],
        'level_training_id': userMap['level_training_id'],
        'track_calories': userMap['track_calories'],
        'coeff_activity': userMap['coeff_activity'],
      });
    }

    EmployeeProfile? employeeProfile;
    if (userMap['ep_user_id'] != null) {
      employeeProfile = EmployeeProfile.fromMap({
        'user_id': userMap['ep_user_id'],
        'specialization': userMap['specialization'],
        'work_experience': userMap['work_experience'],
        'can_maintain_equipment': userMap['can_maintain_equipment'],
      });
    }

    InstructorProfile? instructorProfile;
    if (userMap['ip_user_id'] != null) {
      instructorProfile = InstructorProfile.fromMap({
        'user_id': userMap['ip_user_id'],
        'is_duty': userMap['ip_is_duty'],
        'can_replace_trainer': userMap['can_replace_trainer'],
        'can_create_plan': userMap['can_create_plan'],
      });
    }

    TrainerProfile? trainerProfile;
    if (userMap['tp_user_id'] != null) {
      trainerProfile = TrainerProfile.fromMap({
        'user_id': userMap['tp_user_id'],
      });
    }

    ManagerProfile? managerProfile;
    if (userMap['mp_user_id'] != null) {
      managerProfile = ManagerProfile.fromMap({
        'user_id': userMap['mp_user_id'],
        'is_duty': userMap['mp_is_duty'],
      });
    }

    return User.fromMap(userMap).copyWith(
      clientProfile: clientProfile,
      employeeProfile: employeeProfile,
      instructorProfile: instructorProfile,
      trainerProfile: trainerProfile,
      managerProfile: managerProfile,
    );
  }

  @override
  Future<User> createUser(
    User user,
    List<String> roleNames, {
    String? creatorId,
    Session? session,
  }) {
    return _withSession(session, (conn) async {
      final login = user.email ?? user.phone;
      if (login == null || login.isEmpty) {
        throw ArgumentError('Для пользователя нужен email или телефон');
      }

      final userResult = await conn.execute(
        Sql.named('''
          INSERT INTO users (
            login, email, password_hash, first_name, last_name, middle_name,
            phone, gender, date_of_birth, created_at, updated_at
          )
          VALUES (
            @login, @email, @password_hash, @first_name, @last_name,
            @middle_name, @phone, @gender, @date_of_birth, @created_at,
            @updated_at
          )
          RETURNING id
        '''),
        parameters: {
          'login': login,
          'email': user.email,
          'password_hash': user.passwordHash,
          'first_name': user.firstName,
          'last_name': user.lastName,
          'middle_name': user.middleName,
          'phone': user.phone,
          'gender': _genderToDb(user.gender),
          'date_of_birth': user.dateOfBirth,
          'created_at': user.createdAt,
          'updated_at': user.updatedAt,
        },
      );

      final newUserId = userResult.first[0] as String;
      final actorId = creatorId ?? newUserId;

      await conn.execute(
        Sql.named('''
          UPDATE users
          SET created_by = @actorId, updated_by = @actorId
          WHERE id = @userId
        '''),
        parameters: {'actorId': actorId, 'userId': newUserId},
      );

      await conn.execute(
        Sql.named('''
          INSERT INTO user_settings (
            user_id, send_notifications, hour_notification, created_by,
            updated_by
          )
          VALUES (@userId, @send, @hour, @actorId, @actorId)
          ON CONFLICT (user_id) DO NOTHING
        '''),
        parameters: {
          'userId': newUserId,
          'send': user.sendNotification,
          'hour': user.hourNotification,
          'actorId': actorId,
        },
      );

      for (final roleName in roleNames) {
        final roleId = await _roleIdByName(roleName, conn);
        await conn.execute(
          Sql.named('''
            INSERT INTO user_roles (
              user_id, role_id, created_by, updated_by
            )
            VALUES (@userId, @roleId, @actorId, @actorId)
            ON CONFLICT (user_id, role_id) DO NOTHING
          '''),
          parameters: {
            'userId': newUserId,
            'roleId': roleId,
            'actorId': actorId,
          },
        );
      }

      final created = await getUserById(newUserId, session: conn);
      if (created == null) {
        throw StateError('Пользователь не найден после создания');
      }
      return created;
    });
  }

  @override
  Future<void> updateUserRoles(
    String userId,
    List<String> newRoleIds, {
    String? updatedBy,
    Session? session,
  }) {
    return _withSession(session, (conn) async {
      final currentResult = await conn.execute(
        Sql.named('SELECT role_id FROM user_roles WHERE user_id = @userId'),
        parameters: {'userId': userId},
      );
      final current = currentResult.map((row) => row[0].toString()).toSet();
      final next = newRoleIds.toSet();

      for (final roleId in current.difference(next)) {
        await conn.execute(
          Sql.named(
            'DELETE FROM user_roles WHERE user_id = @userId AND role_id = @roleId',
          ),
          parameters: {'userId': userId, 'roleId': roleId},
        );
      }

      for (final roleId in next.difference(current)) {
        await conn.execute(
          Sql.named('''
            INSERT INTO user_roles (
              user_id, role_id, created_by, updated_by
            )
            VALUES (@userId, @roleId, @updatedBy, @updatedBy)
            ON CONFLICT (user_id, role_id) DO UPDATE
              SET updated_at = NOW(), updated_by = @updatedBy
          '''),
          parameters: {
            'userId': userId,
            'roleId': roleId,
            'updatedBy': updatedBy,
          },
        );
      }
    });
  }

  @override
  Future<User?> updateUser({
    required String id,
    String? email,
    String? firstName,
    String? lastName,
    String? middleName,
    String? phone,
    String? gender,
    DateTime? dateOfBirth,
    String? updatedBy,
    bool archivedAtProvided = false,
    DateTime? archivedAt,
    String? archivedReason,
    bool updateSettings = false,
    bool? sendNotification,
    int? hourNotification,
    Session? session,
  }) {
    return _withSession(session, (conn) async {
      try {
        final setParts = <String>[];
        final parameters = <String, dynamic>{'id': id};

        if (email != null) {
          setParts.add('email = @email');
          setParts.add('login = @email');
          parameters['email'] = email;
        }
        if (firstName != null) {
          setParts.add('first_name = @firstName');
          parameters['firstName'] = firstName;
        }
        if (lastName != null) {
          setParts.add('last_name = @lastName');
          parameters['lastName'] = lastName;
        }
        if (middleName != null) {
          setParts.add('middle_name = @middleName');
          parameters['middleName'] = middleName;
        }
        if (phone != null) {
          setParts.add('phone = @phone');
          parameters['phone'] = phone;
        }
        if (gender != null) {
          setParts.add('gender = @gender');
          parameters['gender'] = _genderToDb(gender);
        }
        if (dateOfBirth != null) {
          setParts.add('date_of_birth = @dateOfBirth');
          parameters['dateOfBirth'] = dateOfBirth;
        }

        if (archivedAtProvided) {
          setParts.add('archived_at = @archivedAt');
          setParts.add('archived_by = @archivedBy');
          setParts.add('archived_reason = @archivedReason');
          parameters['archivedAt'] = archivedAt;
          parameters['archivedBy'] = archivedAt == null ? null : updatedBy;
          parameters['archivedReason'] = archivedAt == null
              ? null
              : archivedReason;
        }

        setParts.add('updated_at = NOW()');
        if (updatedBy != null) {
          setParts.add('updated_by = @updatedBy');
          parameters['updatedBy'] = updatedBy;
        }

        final sql =
            '''
          UPDATE users
          SET ${setParts.join(', ')}
          WHERE id = @id
        ''';

        await conn.execute(Sql.named(sql), parameters: parameters);

        if (updateSettings) {
          await _upsertSettings(
            conn,
            userId: id,
            sendNotifications: sendNotification,
            hourNotification: hourNotification,
            updatedBy: updatedBy ?? id,
          );
        }

        return await getUserById(id, session: conn);
      } catch (e) {
        appLog.error('❌ updateUser error: $e');
        rethrow;
      }
    });
  }

  @override
  Future<void> updateClientProfile({
    required String userId,
    String? goalTrainingId,
    String? levelTrainingId,
    bool? trackCalories,
    double? coeffActivity,
    required String updatedBy,
    Session? session,
  }) async {
    final conn = session ?? await _connection;
    try {
      final setParts = <String>[];
      final parameters = <String, dynamic>{'userId': userId};

      if (goalTrainingId != null) {
        setParts.add('goal_training_id = @goalTrainingId');
        parameters['goalTrainingId'] = goalTrainingId;
      }
      if (levelTrainingId != null) {
        setParts.add('level_training_id = @levelTrainingId');
        parameters['levelTrainingId'] = levelTrainingId;
      }
      if (trackCalories != null) {
        setParts.add('track_calories = @trackCalories');
        parameters['trackCalories'] = trackCalories;
      }
      if (coeffActivity != null) {
        setParts.add('coeff_activity = @coeffActivity');
        parameters['coeffActivity'] = coeffActivity;
      }

      if (setParts.isEmpty) {
        return;
      }

      setParts.add('updated_at = NOW()');
      setParts.add('updated_by = @updatedBy');
      parameters['updatedBy'] = updatedBy;

      final sql =
          '''
        UPDATE client_profiles
        SET ${setParts.join(', ')}, created_by = COALESCE(created_by, @updatedBy)
        WHERE user_id = @userId
      ''';

      final result = await conn.execute(Sql.named(sql), parameters: parameters);

      if (result.affectedRows == 0) {
        await conn.execute(
          Sql.named('''
            INSERT INTO client_profiles (
              user_id, goal_training_id, level_training_id, track_calories,
              coeff_activity, created_by, updated_by
            )
            VALUES (
              @userId, @goalTrainingId, @levelTrainingId, @trackCalories,
              @coeffActivity, @updatedBy, @updatedBy
            )
            ON CONFLICT (user_id) DO UPDATE SET
              goal_training_id = COALESCE(
                @goalTrainingId, client_profiles.goal_training_id
              ),
              level_training_id = COALESCE(
                @levelTrainingId, client_profiles.level_training_id
              ),
              track_calories = COALESCE(
                @trackCalories, client_profiles.track_calories
              ),
              coeff_activity = COALESCE(
                @coeffActivity, client_profiles.coeff_activity
              ),
              updated_at = NOW(),
              updated_by = @updatedBy
          '''),
          parameters: {
            'userId': userId,
            'goalTrainingId': goalTrainingId,
            'levelTrainingId': levelTrainingId,
            'trackCalories': trackCalories,
            'coeffActivity': coeffActivity,
            'updatedBy': updatedBy,
          },
        );
      }
    } catch (e) {
      appLog.error('❌ updateClientProfile error: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateEmployeeProfile({
    required String userId,
    String? specialization,
    int? workExperience,
    bool? canMaintainEquipment,
    required String updatedBy,
    Session? session,
  }) async {
    final conn = session ?? await _connection;
    try {
      final setParts = <String>[];
      final parameters = <String, dynamic>{'userId': userId};

      if (specialization != null) {
        setParts.add('specialization = @specialization');
        parameters['specialization'] = specialization;
      }
      if (workExperience != null) {
        setParts.add('work_experience = @workExperience');
        parameters['workExperience'] = workExperience;
      }
      if (canMaintainEquipment != null) {
        setParts.add('can_maintain_equipment = @canMaintainEquipment');
        parameters['canMaintainEquipment'] = canMaintainEquipment;
      }

      if (setParts.isEmpty) {
        return;
      }

      setParts.add('updated_at = NOW()');
      setParts.add('updated_by = @updatedBy');
      parameters['updatedBy'] = updatedBy;

      final sql =
          '''
        UPDATE employee_profiles
        SET ${setParts.join(', ')}, created_by = COALESCE(created_by, @updatedBy)
        WHERE user_id = @userId
      ''';

      final result = await conn.execute(Sql.named(sql), parameters: parameters);

      if (result.affectedRows == 0) {
        await conn.execute(
          Sql.named('''
            INSERT INTO employee_profiles (
              user_id, specialization, work_experience, can_maintain_equipment,
              created_by, updated_by
            )
            VALUES (
              @userId, @specialization, @workExperience,
              @canMaintainEquipment, @updatedBy, @updatedBy
            )
            ON CONFLICT (user_id) DO UPDATE SET
              specialization = COALESCE(
                @specialization, employee_profiles.specialization
              ),
              work_experience = COALESCE(
                @workExperience, employee_profiles.work_experience
              ),
              can_maintain_equipment = COALESCE(
                @canMaintainEquipment,
                employee_profiles.can_maintain_equipment
              ),
              updated_at = NOW(),
              updated_by = @updatedBy
          '''),
          parameters: {
            'userId': userId,
            'specialization': specialization,
            'workExperience': workExperience,
            'canMaintainEquipment': canMaintainEquipment,
            'updatedBy': updatedBy,
          },
        );
      }
    } catch (e) {
      appLog.error('❌ updateEmployeeProfile error: $e');
      rethrow;
    }
  }

  @override
  Future<bool> archiveUser({
    required String id,
    required String archivedBy,
    String? reason,
    Session? session,
  }) async {
    final conn = session ?? await _connection;
    final result = await conn.execute(
      Sql.named('''
        UPDATE users
        SET archived_at = NOW(),
            archived_by = @archivedBy,
            archived_reason = @reason,
            updated_at = NOW(),
            updated_by = @archivedBy
        WHERE id = @id AND archived_at IS NULL
      '''),
      parameters: {'id': id, 'archivedBy': archivedBy, 'reason': reason},
    );
    return result.affectedRows > 0;
  }

  @override
  Future<void> updateUserPassword(
    String userId,
    String newPasswordHash, {
    String? updatedBy,
    Session? session,
  }) async {
    final conn = session ?? await _connection;
    try {
      await conn.execute(
        Sql.named('''
          UPDATE users
          SET password_hash = @passwordHash,
              updated_at = NOW(),
              updated_by = COALESCE(@updatedBy, updated_by)
          WHERE id = @userId
        '''),
        parameters: {
          'passwordHash': newPasswordHash,
          'updatedBy': updatedBy,
          'userId': userId,
        },
      );
    } catch (e) {
      appLog.error('❌ updateUserPassword error: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateUserPhotoUrl(
    String userId,
    String photoUrl,
    String updaterId, {
    Session? session,
  }) async {
    final conn = session ?? await _connection;
    try {
      await conn.execute(
        Sql.named('''
          UPDATE users
          SET photo_url = @photoUrl, updated_at = NOW(), updated_by = @updaterId
          WHERE id = @userId
        '''),
        parameters: {
          'photoUrl': photoUrl,
          'updaterId': updaterId,
          'userId': userId,
        },
      );
    } catch (e) {
      appLog.error('❌ updateUserPhotoUrl error: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>?> getUserSettings(
    String userId, {
    Session? session,
  }) async {
    final conn = session ?? await _connection;
    final result = await conn.execute(
      Sql.named('''
        SELECT send_notifications, hour_notification, notification_email,
               notification_push
        FROM user_settings
        WHERE user_id = @userId
      '''),
      parameters: {'userId': userId},
    );
    return result.isEmpty ? null : result.first.toColumnMap();
  }

  @override
  Future<void> upsertUserSettings({
    required String userId,
    bool? sendNotifications,
    int? hourNotification,
    required String updatedBy,
    Session? session,
  }) {
    return _withSession(session, (conn) async {
      await _upsertSettings(
        conn,
        userId: userId,
        sendNotifications: sendNotifications,
        hourNotification: hourNotification,
        updatedBy: updatedBy,
      );
    });
  }

  Future<void> _upsertSettings(
    Session conn, {
    required String userId,
    bool? sendNotifications,
    int? hourNotification,
    required String updatedBy,
  }) async {
    await conn.execute(
      Sql.named('''
        INSERT INTO user_settings (
          user_id, send_notifications, hour_notification, created_by, updated_by
        )
        VALUES (@userId, COALESCE(@send, true), COALESCE(@hour, 2),
                @updatedBy, @updatedBy)
        ON CONFLICT (user_id) DO UPDATE SET
          send_notifications = COALESCE(
            @send, user_settings.send_notifications
          ),
          hour_notification = COALESCE(
            @hour, user_settings.hour_notification
          ),
          updated_at = NOW(),
          updated_by = @updatedBy
      '''),
      parameters: {
        'userId': userId,
        'send': sendNotifications,
        'hour': hourNotification,
        'updatedBy': updatedBy,
      },
    );
  }

  Future<String> _roleIdByName(String roleName, Session conn) async {
    final roleResult = await conn.execute(
      Sql.named('SELECT id FROM roles WHERE name = @roleName'),
      parameters: {'roleName': roleName},
    );
    if (roleResult.isEmpty) {
      throw StateError('Роль не найдена: $roleName');
    }
    return roleResult.first[0] as String;
  }

  int? _genderToDb(String? gender) {
    if (gender == null) return null;
    return gender == 'мужской' ? 0 : 1;
  }

  Future<User> _fetchAndAttachProfiles(User user, Session context) async {
    final conn = context;
    var updatedUser = user;

    final isClient = user.roles.any((r) => r.name == 'client');
    final isEmployee = user.roles.any(
      (r) => ['instructor', 'trainer', 'manager'].contains(r.name),
    );

    if (isClient) {
      final profileResult = await conn.execute(
        Sql.named('SELECT * FROM client_profiles WHERE user_id = @id'),
        parameters: {'id': user.id},
      );
      if (profileResult.isNotEmpty) {
        updatedUser = updatedUser.copyWith(
          clientProfile: ClientProfile.fromMap(
            profileResult.first.toColumnMap(),
          ),
        );
      }
    }

    if (isEmployee) {
      final employeeProfileResult = await conn.execute(
        Sql.named('SELECT * FROM employee_profiles WHERE user_id = @id'),
        parameters: {'id': user.id},
      );
      if (employeeProfileResult.isNotEmpty) {
        updatedUser = updatedUser.copyWith(
          employeeProfile: EmployeeProfile.fromMap(
            employeeProfileResult.first.toColumnMap(),
          ),
        );
      }

      if (user.roles.any((r) => r.name == 'instructor')) {
        final profileResult = await conn.execute(
          Sql.named('SELECT * FROM instructor_profiles WHERE user_id = @id'),
          parameters: {'id': user.id},
        );
        if (profileResult.isNotEmpty) {
          updatedUser = updatedUser.copyWith(
            instructorProfile: InstructorProfile.fromMap(
              profileResult.first.toColumnMap(),
            ),
          );
        }
      }
      if (user.roles.any((r) => r.name == 'trainer')) {
        final profileResult = await conn.execute(
          Sql.named('SELECT * FROM trainer_profiles WHERE user_id = @id'),
          parameters: {'id': user.id},
        );
        if (profileResult.isNotEmpty) {
          updatedUser = updatedUser.copyWith(
            trainerProfile: TrainerProfile.fromMap(
              profileResult.first.toColumnMap(),
            ),
          );
        }
      }
      if (user.roles.any((r) => r.name == 'manager')) {
        final profileResult = await conn.execute(
          Sql.named('SELECT * FROM manager_profiles WHERE user_id = @id'),
          parameters: {'id': user.id},
        );
        if (profileResult.isNotEmpty) {
          updatedUser = updatedUser.copyWith(
            managerProfile: ManagerProfile.fromMap(
              profileResult.first.toColumnMap(),
            ),
          );
        }
      }
    }
    return updatedUser;
  }

  // --- Manager/Client/Instructor relationships ---
  @override
  Future<List<User>> getClientsForManager(String managerId) async {
    // ... implementation
    return [];
  }

  @override
  Future<void> assignClientsToManager(
    String managerId,
    List<String> clientIds,
  ) async {
    // ... implementation
  }

  @override
  Future<List<String>> getAssignedClientIds(String managerId) async {
    // ... implementation
    return [];
  }

  @override
  Future<List<User>> getInstructorsForManager(String managerId) async {
    // ... implementation
    return [];
  }

  @override
  Future<void> assignInstructorsToManager(
    String managerId,
    List<String> instructorIds,
  ) async {
    // ... implementation
  }

  @override
  Future<List<String>> getAssignedInstructorIds(String managerId) async {
    // ... implementation
    return [];
  }

  @override
  Future<List<User>> getTrainersForManager(String managerId) async {
    // ... implementation
    return [];
  }

  @override
  Future<void> assignTrainersToManager(
    String managerId,
    List<String> trainerIds,
  ) async {
    // ... implementation
  }

  @override
  Future<List<String>> getAssignedTrainerIds(String managerId) async {
    // ... implementation
    return [];
  }

  @override
  Future<List<User>> getClientsForInstructor(String instructorId) async {
    // ... implementation
    return [];
  }

  @override
  Future<List<User>> getTrainersForInstructor(String instructorId) async {
    // ... implementation
    return [];
  }

  @override
  Future<User?> getManagerForInstructor(String instructorId) async {
    // ... implementation
    return null;
  }

  @override
  Future<User?> getTrainerForClient(String clientId) async {
    try {
      final conn = await _connection;
      final results = await conn.execute(
        Sql.named(
          'SELECT trainer_id FROM trainer_clients WHERE client_id = @clientId LIMIT 1',
        ),
        parameters: {'clientId': clientId},
      );

      if (results.isEmpty) {
        return null;
      }

      final trainerId = results.first[0] as String;
      return await getUserById(trainerId);
    } catch (e) {
      appLog.error('❌ getTrainerForClient error: $e');
      rethrow;
    }
  }

  @override
  Future<User?> getInstructorForClient(String clientId) async {
    try {
      final conn = await _connection;
      final results = await conn.execute(
        Sql.named(
          'SELECT instructor_id FROM instructor_clients WHERE client_id = @clientId LIMIT 1',
        ),
        parameters: {'clientId': clientId},
      );

      if (results.isEmpty) {
        return null;
      }

      final instructorId = results.first[0] as String;
      return await getUserById(instructorId);
    } catch (e) {
      appLog.error('❌ getInstructorForClient error: $e');
      rethrow;
    }
  }

  @override
  Future<User?> getManagerForClient(String clientId) async {
    try {
      final conn = await _connection;
      final results = await conn.execute(
        Sql.named(
          'SELECT manager_id FROM manager_clients WHERE client_id = @clientId LIMIT 1',
        ),
        parameters: {'clientId': clientId},
      );

      if (results.isEmpty) {
        return null;
      }

      final managerId = results.first[0] as String;
      return await getUserById(managerId);
    } catch (e) {
      appLog.error('❌ getManagerForClient error: $e');
      rethrow;
    }
  }
}
