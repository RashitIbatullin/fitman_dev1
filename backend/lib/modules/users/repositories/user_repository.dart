import 'package:postgres/postgres.dart';

import '../../../../config/database.dart';
import 'package:fitman_common/fitman_common.dart';

abstract class UserRepository {
  Future<List<Role>> getAllRoles();
  Future<Role?> getRoleByName(String roleName);
  Future<List<Role>> getRolesForUser(String userId, [Session? context]);
  Future<List<User>> getAllUsers({bool? isArchived, String? role, Session? context});
  Future<User?> getUserByEmail(String email, [Session? context]);
  Future<User?> getUserByPhone(String phone, [Session? context]);
  Future<User?> getUserById(String id, [Session? context]);
  Future<User> createUser(User user, List<String> roleNames, [String? creatorId]);
  Future<void> updateUserRoles(String userId, List<String> newRoleIds);
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
    DateTime? archivedAt,
    String? archivedReason,
  });
  Future<void> updateClientProfile({
    required String userId,
    String? goalTrainingId,
    String? levelTrainingId,
    bool? trackCalories,
    double? coeffActivity,
    required String updatedBy,
  });
  Future<void> updateEmployeeProfile({
    required String userId,
    String? specialization,
    int? workExperience,
    bool? canMaintainEquipment,
    required String updatedBy,
  });
  Future<bool> deleteUser(String id);
  Future<void> updateUserPassword(String userId, String newPasswordHash);
  Future<void> updateUserPhotoUrl(String userId, String photoUrl, String updaterId);

  // Manager/Client/Instructor relationships
  Future<List<User>> getClientsForManager(String managerId);
  Future<void> assignClientsToManager(String managerId, List<String> clientIds);
  Future<List<String>> getAssignedClientIds(String managerId);
  Future<List<User>> getInstructorsForManager(String managerId);
  Future<void> assignInstructorsToManager(String managerId, List<String> instructorIds);
  Future<List<String>> getAssignedInstructorIds(String managerId);
  Future<List<User>> getTrainersForManager(String managerId);
  Future<void> assignTrainersToManager(String managerId, List<String> trainerIds);
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

  @override
  Future<List<Role>> getAllRoles() async {
    try {
      final conn = await _connection;
      final results = await conn.execute('''
        SELECT id, name, title, icon FROM roles
      ''');
      return results.map((row) => Role.fromMap(row.toColumnMap())).toList();
    } catch (e) {
      print('❌ getAllRoles error: $e');
      rethrow;
    }
  }

  @override
  Future<Role?> getRoleByName(String roleName) async {
    try {
      final conn = await _connection;
      final results = await conn.execute(
        Sql.named('SELECT id, name, title, icon FROM roles WHERE name = @roleName'),
        parameters: {'roleName': roleName},
      );
      if (results.isEmpty) return null;
      return Role.fromMap(results.first.toColumnMap());
    } catch (e) {
      print('❌ getRoleByName error: $e');
      rethrow;
    }
  }

  @override
  Future<List<Role>> getRolesForUser(String userId, [Session? context]) async {
    try {
      final conn = context ?? await _connection;
      final results = await conn.execute(
        Sql.named('''
          SELECT r.id, r.name, r.title, r.icon
          FROM roles r
          INNER JOIN user_roles ur ON r.id = ur.role_id
          WHERE ur.user_id = @userId
        '''),
        parameters: {'userId': userId},
      );
      return results.map((row) => Role.fromMap(row.toColumnMap())).toList();
    } catch (e) {
      print('❌ getRolesForUser error: $e');
      rethrow;
    }
  }

  @override
  Future<List<User>> getAllUsers({bool? isArchived, String? role, Session? context}) async {
    try {
      final conn = context ?? await _connection;

      final whereClauses = <String>[];
      final parameters = <String, dynamic>{}; // Parameters for named SQL

      if (isArchived != null) {
        if (isArchived) {
          whereClauses.add('u.archived_at IS NOT NULL');
        } else {
          whereClauses.add('u.archived_at IS NULL');
        }
      }
      
      String joinRoles = '';
      if (role != null && role != 'all') { // Check for 'all' as well
        joinRoles = 'INNER JOIN user_roles ur ON u.id = ur.user_id INNER JOIN roles r ON ur.role_id = r.id';
        whereClauses.add('r.name = @roleName');
        parameters['roleName'] = role;
      }

      final whereString = whereClauses.isNotEmpty ? 'WHERE ${whereClauses.join(' AND ')}' : '';

      final query = '''
        SELECT 
          u.id, u.email, u.password_hash, u.first_name, u.last_name, u.middle_name, 
          u.phone, u.gender, u.date_of_birth, u.photo_url, u.created_at, u.updated_at, u.archived_at,
          cp.user_id as cp_user_id, cp.goal_training_id, cp.level_training_id, 
          cp.track_calories, cp.coeff_activity,
          ep.user_id as ep_user_id, ep.specialization, ep.work_experience, ep.can_maintain_equipment,
          ip.user_id as ip_user_id, ip.is_duty as ip_is_duty, ip.can_replace_trainer, ip.can_create_plan,
          tp.user_id as tp_user_id,
          mp.user_id as mp_user_id, mp.is_duty as mp_is_duty
        FROM users u
        LEFT JOIN client_profiles cp ON u.id = cp.user_id
        LEFT JOIN employee_profiles ep ON u.id = ep.user_id
        LEFT JOIN instructor_profiles ip ON u.id = ip.user_id
        LEFT JOIN trainer_profiles tp ON u.id = tp.user_id
        LEFT JOIN manager_profiles mp ON u.id = mp.user_id
        $joinRoles
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

        var user = User.fromMap(userMap).copyWith(
          clientProfile: clientProfile,
          employeeProfile: employeeProfile,
          instructorProfile: instructorProfile,
          trainerProfile: trainerProfile,
          managerProfile: managerProfile,
        );

        final roles = await getRolesForUser(user.id, conn);
        user = user.copyWith(roles: roles);
        users.add(user);
      }
      return users;
    } catch (e) {
      print('❌ getAllUsers error: $e');
      rethrow;
    }
  }

  @override
  Future<User?> getUserByEmail(String email, [Session? context]) async {
    try {
      final conn = context ?? await _connection;

      final sql = '''
        SELECT id, email, password_hash, first_name, last_name, middle_name, phone, gender, date_of_birth, photo_url, created_at, updated_at, archived_at
        FROM users
        WHERE email = @email
        LIMIT 1
      ''';

      final results = await conn.execute(
        Sql.named(sql),
        parameters: {
          'email': email,
        },
      );

      if (results.isEmpty) return null;

      final userMap = results.first.toColumnMap();
      var user = User.fromMap(userMap);
      final roles = await getRolesForUser(user.id, conn);
      user = user.copyWith(roles: roles);

      // Fetch profiles
      user = await _fetchAndAttachProfiles(user, conn);

      return user;
    } catch (e) {
      print('❌ getUserByEmail error: $e');
      rethrow;
    }
  }

  @override
  Future<User?> getUserByPhone(String phone, [Session? context]) async {
    try {
      final conn = context ?? await _connection;

      final sql = '''
        SELECT id, email, password_hash, first_name, last_name, middle_name, phone, gender, date_of_birth, photo_url, created_at, updated_at, archived_at
        FROM users
        WHERE phone = @phone
        LIMIT 1
      ''';

      final results = await conn.execute(
        Sql.named(sql),
        parameters: {
          'phone': phone,
        },
      );

      if (results.isEmpty) return null;

      final userMap = results.first.toColumnMap();
      var user = User.fromMap(userMap);
      final roles = await getRolesForUser(user.id, conn);
      user = user.copyWith(roles: roles);

      // Fetch profiles
      user = await _fetchAndAttachProfiles(user, conn);

      return user;
    } catch (e) {
      print('❌ getUserByPhone error: $e');
      rethrow;
    }
  }

  @override
  Future<User?> getUserById(String id, [Session? context]) async {
    try {
      final conn = context ?? await _connection;

      final sql = '''
        SELECT id, email, password_hash, first_name, last_name, middle_name, phone, gender, date_of_birth, photo_url, created_at, updated_at, archived_at
        FROM users
        WHERE id = @id
        LIMIT 1
      ''';

      final results = await conn.execute(
        Sql.named(sql),
        parameters: {
          'id': id,
        },
      );

      if (results.isEmpty) return null;

      final userMap = results.first.toColumnMap();
      var user = User.fromMap(userMap);
      final roles = await getRolesForUser(user.id, conn);
      user = user.copyWith(roles: roles);

      // Fetch profiles
      user = await _fetchAndAttachProfiles(user, conn);

      return user;
    } catch (e) {
      print('❌ getUserById error: $e');
      rethrow;
    }
  }

  @override
  Future<User> createUser(User user, List<String> roleNames, [String? creatorId]) async {
    final conn = await _connection;
    return await conn.runTx((ctx) async {
      // 1. Вставить пользователя в таблицу users и получить его ID
      final userResult = await ctx.execute(
        Sql.named('''
          INSERT INTO users (login, email, password_hash, first_name, last_name, phone, gender, date_of_birth, created_at, updated_at)
          VALUES (@login, @email, @password_hash, @first_name, @last_name, @phone, @gender, @date_of_birth, @created_at, @updated_at)
          RETURNING id
        '''),
        parameters: {
          'login': user.email, // Используем email как логин по умолчанию
          'email': user.email,
          'password_hash': user.passwordHash,
          'first_name': user.firstName,
          'last_name': user.lastName,
          'phone': user.phone,
          'gender': user.gender == 'мужской' ? 0 : 1,
          'date_of_birth': user.dateOfBirth,
          'created_at': user.createdAt,
          'updated_at': user.updatedAt,
        },
      );

      final newUserId = userResult.first[0] as String;
      final finalCreatorId = creatorId ?? newUserId;

      // 2. Обновить created_by и updated_by
      await ctx.execute(
        Sql.named('''
          UPDATE users 
          SET created_by = @creatorId, updated_by = @creatorId 
          WHERE id = @userId
        '''),
        parameters: {
          'creatorId': finalCreatorId,
          'userId': newUserId,
        },
      );


      // 3. Связать пользователя с ролями
      for (final roleName in roleNames) {
        final roleResult = await ctx.execute(
          Sql.named('SELECT id FROM roles WHERE name = @roleName'),
          parameters: {'roleName': roleName},
        );

        if (roleResult.isEmpty) {
          throw Exception('Role not found: $roleName');
        }
        final roleId = roleResult.first[0] as String;

        await ctx.execute(
          Sql.named('INSERT INTO user_roles (user_id, role_id, created_by, updated_by) VALUES (@userId, @roleId, @creatorId, @creatorId)'),
          parameters: {
            'userId': newUserId,
            'roleId': roleId,
            'creatorId': finalCreatorId,
          },
        );
      }

      // 4. Вернуть созданного пользователя со всей информацией
      final createdUserResult = await ctx.execute(
        Sql.named('SELECT * FROM users WHERE id = @id'),
        parameters: {'id': newUserId},
      );
      final userMap = createdUserResult.first.toColumnMap();
      final roles = await getRolesForUser(newUserId, ctx);
      final newUser = User.fromMap(userMap).copyWith(roles: roles);
      return newUser;
    });
  }

  @override
  Future<void> updateUserRoles(String userId, List<String> newRoleIds) async {
    final conn = await _connection;
    await conn.runTx((ctx) async {
      // Удаляем все текущие роли пользователя
      await ctx.execute(
        Sql.named('DELETE FROM user_roles WHERE user_id = @userId'),
        parameters: {'userId': userId},
      );

      // Добавляем новые роли
      for (final roleId in newRoleIds) {
        await ctx.execute(
          Sql.named('INSERT INTO user_roles (user_id, role_id) VALUES (@userId, @roleId)'),
          parameters: {'userId': userId, 'roleId': roleId},
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
    DateTime? archivedAt,
    String? archivedReason,
  }) async {
    final conn = await _connection;
    return conn.runTx((ctx) async {
      try {
        final setParts = <String>[];
        final parameters = <String, dynamic>{'id': id};

        if (email != null) {
          setParts.add('email = @email');
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
          parameters['gender'] = gender == 'мужской' ? 0 : 1;
        }
        if (dateOfBirth != null) {
          setParts.add('date_of_birth = @dateOfBirth');
          parameters['dateOfBirth'] = dateOfBirth;
        }
        
        setParts.add('archived_at = @archivedAt');
        parameters['archivedAt'] = archivedAt;

        if (archivedReason != null) { // Conditionally add archivedReason
          setParts.add('archived_reason = @archivedReason');
          parameters['archivedReason'] = archivedReason;
        }


        if (setParts.isEmpty) {
          return await getUserById(id, ctx);
        }

        setParts.add('updated_at = @updatedAt');
        parameters['updatedAt'] = DateTime.now();
        if (updatedBy != null) {
          setParts.add('updated_by = @updatedBy');
          parameters['updatedBy'] = updatedBy;
        }

        final sql = '''
          UPDATE users 
          SET ${setParts.join(', ')}
          WHERE id = @id
        ''';

        await ctx.execute(
          Sql.named(sql),
          parameters: parameters,
        );

        return await getUserById(id, ctx);
      } catch (e) {
        print('❌ updateUser error: $e');
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
  }) async {
    try {
      final conn = await _connection;

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
        // нечего обновлять
        return;
      }

      setParts.add('updated_at = @updatedAt');
      parameters['updatedAt'] = DateTime.now();
      setParts.add('updated_by = @updatedBy');
      parameters['updatedBy'] = updatedBy;

      final sql = '''
        UPDATE client_profiles
        SET ${setParts.join(', ')}
        WHERE user_id = @userId
      ''';

      final result = await conn.execute(
        Sql.named(sql),
        parameters: parameters,
      );

      if (result.affectedRows == 0) {
        await conn.execute(
          Sql.named('''
            INSERT INTO client_profiles (user_id, goal_training_id, level_training_id, track_calories, coeff_activity, created_by, updated_by)
            VALUES (@userId, @goalTrainingId, @levelTrainingId, @trackCalories, @coeffActivity, @updatedBy, @updatedBy)
            ON CONFLICT (user_id) DO UPDATE SET
              goal_training_id = COALESCE(@goalTrainingId, client_profiles.goal_training_id),
              level_training_id = COALESCE(@levelTrainingId, client_profiles.level_training_id),
              track_calories = COALESCE(@trackCalories, client_profiles.track_calories),
              coeff_activity = COALESCE(@coeffActivity, client_profiles.coeff_activity),
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
          }
        );
      }

    } catch (e) {
      print('❌ updateClientProfile error: $e');
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
  }) async {
    try {
      final conn = await _connection;

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
        return; // Nothing to update
      }

      setParts.add('updated_at = @updatedAt');
      parameters['updatedAt'] = DateTime.now();
      setParts.add('updated_by = @updatedBy');
      parameters['updatedBy'] = updatedBy;

      final sql = '''
        UPDATE employee_profiles
        SET ${setParts.join(', ')}
        WHERE user_id = @userId
      ''';

      final result = await conn.execute(
        Sql.named(sql),
        parameters: parameters,
      );

      if (result.affectedRows == 0) {
        await conn.execute(
          Sql.named('''
            INSERT INTO employee_profiles (user_id, specialization, work_experience, can_maintain_equipment, created_by, updated_by)
            VALUES (@userId, @specialization, @workExperience, @canMaintainEquipment, @updatedBy, @updatedBy)
            ON CONFLICT (user_id) DO UPDATE SET
              specialization = COALESCE(@specialization, employee_profiles.specialization),
              work_experience = COALESCE(@workExperience, employee_profiles.work_experience),
              can_maintain_equipment = COALESCE(@canMaintainEquipment, employee_profiles.can_maintain_equipment),
              updated_at = NOW(),
              updated_by = @updatedBy
          '''),
          parameters: {
            'userId': userId,
            'specialization': specialization,
            'workExperience': workExperience,
            'canMaintainEquipment': canMaintainEquipment,
            'updatedBy': updatedBy,
          }
        );
      }

    } catch (e) {
      print('❌ updateEmployeeProfile error: $e');
      rethrow;
    }
  }

  @override
  Future<bool> deleteUser(String id) async {
    try {
      final conn = await _connection;

      final sql = '''
        UPDATE users
        SET archived_at = NOW()
        WHERE id = @id
      ''';

      final results = await conn.execute(
        Sql.named(sql),
        parameters: {
          'id': id,
        },
      );

      return results.affectedRows > 0;
    } catch (e) {
      print('❌ deleteUser error: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> updateUserPassword(String userId, String newPasswordHash) async {
    try {
      final conn = await _connection;
      await conn.execute(
        Sql.named('''
          UPDATE users
          SET password_hash = @passwordHash, updated_at = @updatedAt
          WHERE id = @userId
        '''),
        parameters: {
          'passwordHash': newPasswordHash,
          'updatedAt': DateTime.now(),
          'userId': userId,
        },
      );
    } catch (e) {
      print('❌ updateUserPassword error: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateUserPhotoUrl(String userId, String photoUrl, String updaterId) async {
    try {
      final conn = await _connection;
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
      print('❌ updateUserPhotoUrl error: $e');
      rethrow;
    }
  }
  
  Future<User> _fetchAndAttachProfiles(User user, Session context) async {
    final conn = context;
    var updatedUser = user;

    final isClient = user.roles.any((r) => r.name == 'client');
    final isEmployee = user.roles.any((r) => ['instructor', 'trainer', 'manager'].contains(r.name));

    if (isClient) {
      final profileResult = await conn.execute(
        Sql.named('SELECT * FROM client_profiles WHERE user_id = @id'),
        parameters: {'id': user.id},
      );
      if (profileResult.isNotEmpty) {
        updatedUser = updatedUser.copyWith(
          clientProfile: ClientProfile.fromMap(profileResult.first.toColumnMap()),
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
          employeeProfile: EmployeeProfile.fromMap(employeeProfileResult.first.toColumnMap()),
        );
      }

      if (user.roles.any((r) => r.name == 'instructor')) {
        final profileResult = await conn.execute(
          Sql.named('SELECT * FROM instructor_profiles WHERE user_id = @id'),
          parameters: {'id': user.id},
        );
        if (profileResult.isNotEmpty) {
          updatedUser = updatedUser.copyWith(
            instructorProfile: InstructorProfile.fromMap(profileResult.first.toColumnMap()),
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
            trainerProfile: TrainerProfile.fromMap(profileResult.first.toColumnMap()),
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
            managerProfile: ManagerProfile.fromMap(profileResult.first.toColumnMap()),
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
  Future<void> assignClientsToManager(String managerId, List<String> clientIds) async {
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
  Future<void> assignInstructorsToManager(String managerId, List<String> instructorIds) async {
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
  Future<void> assignTrainersToManager(String managerId, List<String> trainerIds) async {
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
        Sql.named('SELECT trainer_id FROM trainer_clients WHERE client_id = @clientId LIMIT 1'),
        parameters: {'clientId': clientId},
      );

      if (results.isEmpty) {
        return null;
      }

      final trainerId = results.first[0] as String;
      return await getUserById(trainerId);
    } catch (e) {
      print('❌ getTrainerForClient error: $e');
      rethrow;
    }
  }
  @override
  Future<User?> getInstructorForClient(String clientId) async {
    try {
      final conn = await _connection;
      final results = await conn.execute(
        Sql.named('SELECT instructor_id FROM instructor_clients WHERE client_id = @clientId LIMIT 1'),
        parameters: {'clientId': clientId},
      );

      if (results.isEmpty) {
        return null;
      }

      final instructorId = results.first[0] as String;
      return await getUserById(instructorId);
    } catch (e) {
      print('❌ getInstructorForClient error: $e');
      rethrow;
    }
  }
  @override
  Future<User?> getManagerForClient(String clientId) async {
    try {
      final conn = await _connection;
      final results = await conn.execute(
        Sql.named('SELECT manager_id FROM manager_clients WHERE client_id = @clientId LIMIT 1'),
        parameters: {'clientId': clientId},
      );

      if (results.isEmpty) {
        return null;
      }

      final managerId = results.first[0] as String;
      return await getUserById(managerId);
    } catch (e) {
      print('❌ getManagerForClient error: $e');
      rethrow;
    }
  }
}
