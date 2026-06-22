import 'package:postgres/postgres.dart';
import '../../../config/database.dart';
import 'package:fitman_common/modules/groups/analytic_group.model.dart';
import 'package:fitman_common/modules/groups/group_schedule.model.dart';
import 'package:fitman_common/modules/groups/training_group.model.dart';
import 'package:fitman_common/modules/groups/training_group_type.model.dart';
import 'package:fitman_common/modules/groups/training_group_replacement_employee.model.dart';
import 'package:fitman_common/modules/groups/training_group_user_remove.model.dart';
import 'package:fitman_common/modules/groups/group_movement.model.dart';

class GroupRepository {
  final Database _db;

  GroupRepository(this._db);

  // --- Training Group Methods ---

  Future<List<TrainingGroup>> getAllTrainingGroups({
    String? searchQuery,
    String? groupTypeId,
    bool? isActive,
    bool? isArchived,
    String? trainerId,
    String? instructorId,
    String? managerId,
  }) async {
    final conn = await _db.connection;
    final List<String> whereClauses = [];
    final Map<String, dynamic> parameters = {};

    if (searchQuery != null && searchQuery.isNotEmpty) {
      whereClauses.add('name ILIKE @searchQuery');
      parameters['searchQuery'] = '%$searchQuery%';
    }
    
    if (groupTypeId != null) {
      whereClauses.add('training_group_type_id = @groupTypeId');
      parameters['groupTypeId'] = groupTypeId;
    }

    if (isActive != null) {
      whereClauses.add('is_active = @isActive');
      parameters['isActive'] = isActive;
    }

    if (isArchived != null) {
      if (isArchived) {
        whereClauses.add('archived_at IS NOT NULL');
      } else {
        whereClauses.add('archived_at IS NULL');
      }
    } else {
      // By default, only show non-archived groups if isArchived is not specified
      whereClauses.add('archived_at IS NULL');
    }

    if (trainerId != null) {
      whereClauses.add('primary_trainer_id = @trainerId');
      parameters['trainerId'] = trainerId;
    }

    if (instructorId != null) {
      whereClauses.add('primary_instructor_id = @instructorId');
      parameters['instructorId'] = instructorId;
    }

    if (managerId != null) {
      whereClauses.add('responsible_manager_id = @managerId');
      parameters['managerId'] = managerId;
    }

    final whereString = whereClauses.isNotEmpty ? 'WHERE ${whereClauses.join(' AND ')}' : '';
    
    final rawQuery = '''
      SELECT tg.*, COUNT(tgm.id)::int AS current_participants
      FROM training_groups tg
      LEFT JOIN training_group_members tgm ON tg.id = tgm.training_group_id
      $whereString
      GROUP BY tg.id
      ORDER BY tg.name ASC
    ''';
    
    final results = await conn.execute(
      Sql.named(rawQuery),
      parameters: parameters,
    );
    return results.map((row) {
      final map = row.toColumnMap();
      return TrainingGroup.fromJson(map);
    }).toList();
  }

  Future<TrainingGroup?> getTrainingGroupById(String id) async {
    final conn = await _db.connection;
    final results = await conn.execute(
      Sql.named('''
        SELECT tg.*, COUNT(tgm.id)::int AS current_participants
        FROM training_groups tg
        LEFT JOIN training_group_members tgm ON tg.id = tgm.training_group_id
        WHERE tg.id = @id AND tg.archived_at IS NULL
        GROUP BY tg.id
      '''),
      parameters: {'id': id},
    );
    if (results.isEmpty) return null;
    return TrainingGroup.fromJson(results.first.toColumnMap());
  }

  Future<TrainingGroup> createTrainingGroup(TrainingGroup group, String creatorId) async {
    final conn = await _db.connection;
    final result = await conn.execute(
      Sql.named('''
        INSERT INTO training_groups (
          name, description, training_group_type_id, primary_trainer_id, primary_instructor_id,
          responsible_manager_id, program_id, goal_id, level_id,
          max_participants, start_date, end_date,
          is_active, chat_id, created_by, updated_by
        )
        VALUES (
          @name, @description, @training_group_type_id, @primary_trainer_id, @primary_instructor_id,
          @responsible_manager_id, @program_id, @goal_id, @level_id,
          @max_participants, @start_date, @end_date,
          @is_active, @chat_id, @created_by, @updated_by
        )
        RETURNING *
      '''),
      parameters: {
        'name': group.name,
        'description': group.description,
        'training_group_type_id': group.trainingGroupTypeId,
        'primary_trainer_id': group.primaryTrainerId,
        'primary_instructor_id': group.primaryInstructorId,
        'responsible_manager_id': group.responsibleManagerId,
        'program_id': group.programId,
        'goal_id': group.goalId,
        'level_id': group.levelId,
        'max_participants': group.maxParticipants,

        'start_date': group.startDate.toIso8601String(),
        'end_date': group.endDate?.toIso8601String(),
        'is_active': group.isActive,
        'chat_id': group.chatId,
        'created_by': creatorId,
        'updated_by': creatorId,
      },
    );
    return TrainingGroup.fromJson(result.first.toColumnMap());
  }

  Future<TrainingGroup> updateTrainingGroup(TrainingGroup group, String updaterId) async {
    final conn = await _db.connection;
    return conn.runTx((session) async {
      // 1. Get current state of the group
      final currentGroupResult = await session.execute(
        Sql.named('SELECT primary_trainer_id, primary_instructor_id, responsible_manager_id FROM training_groups WHERE id = @id'),
        parameters: {'id': group.id},
      );
      if (currentGroupResult.isEmpty) {
        throw ArgumentError('Group not found.');
      }
      final currentGroup = currentGroupResult.first.toColumnMap();

      // 2. Update the group
      final result = await session.execute(
        Sql.named('''
          UPDATE training_groups
          SET
            name = @name,
            description = @description,
            training_group_type_id = @training_group_type_id,
            primary_trainer_id = @primary_trainer_id,
            primary_instructor_id = @primary_instructor_id,
            responsible_manager_id = @responsible_manager_id,
            program_id = @program_id,
            goal_id = @goal_id,
            level_id = @level_id,
            max_participants = @max_participants,
            start_date = @start_date,
            end_date = @end_date,
            is_active = @is_active,
            chat_id = @chat_id,
            updated_by = @updated_by,
            updated_at = NOW()
          WHERE id = @id
          RETURNING *
        '''),
        parameters: {
          'id': group.id,
          'name': group.name,
          'description': group.description,
          'training_group_type_id': group.trainingGroupTypeId,
          'primary_trainer_id': group.primaryTrainerId,
          'primary_instructor_id': group.primaryInstructorId,
          'responsible_manager_id': group.responsibleManagerId,
          'program_id': group.programId,
          'goal_id': group.goalId,
          'level_id': group.levelId,
          'max_participants': group.maxParticipants,
          'start_date': group.startDate.toIso8601String(),
          'end_date': group.endDate?.toIso8601String(),
          'is_active': group.isActive,
          'chat_id': group.chatId,
          'updated_by': updaterId,
        },
      );
      final updatedGroup = TrainingGroup.fromJson(result.first.toColumnMap());

      // 3. Log changes in staff
      final staffFields = {
        'primary_trainer_id': 'trainer',
        'primary_instructor_id': 'instructor',
        'responsible_manager_id': 'manager',
      };

      for (final entry in staffFields.entries) {
        final fieldName = entry.key;
        final oldStaffId = currentGroup[fieldName] as String?;
        final newStaffId = _getStaffIdByField(group, fieldName);

        if (oldStaffId != newStaffId) {
          if (oldStaffId != null && newStaffId != null) {
            await session.execute(
              Sql.named(r'''
                INSERT INTO training_group_replacement_employees (
                  group_id, old_employee_id, new_employee_id, date, reason, initiator_id
                )
                VALUES (
                  @groupId, @oldStaffId, @newStaffId, NOW(), @reason, @initiatorId
                )
              '''),
              parameters: {
                'groupId': group.id,
                'oldStaffId': oldStaffId,
                'newStaffId': newStaffId,
                'reason': 'Автоматическое обновление персонала группы',
                'initiatorId': updaterId,
              },
            );
          } else if (oldStaffId != null && newStaffId == null) {
            await session.execute(
              Sql.named(r'''
                INSERT INTO training_group_users_remove (
                  group_id, user_id, user_role, removed_at, reason, initiator_id
                )
                VALUES (
                  @groupId, @userId, @userRole, NOW(), @reason, @initiatorId
                )
              '''),
              parameters: {
                'groupId': group.id,
                'userId': oldStaffId,
                'userRole': entry.value,
                'reason': 'Автоматическое обновление персонала группы',
                'initiatorId': updaterId,
              },
            );
          }
        }
      }

      return updatedGroup;
    });
  }

  String? _getStaffIdByField(TrainingGroup group, String fieldName) {
    switch (fieldName) {
      case 'primary_trainer_id': return group.primaryTrainerId;
      case 'primary_instructor_id': return group.primaryInstructorId;
      case 'responsible_manager_id': return group.responsibleManagerId;
      default: return null;
    }
  }

  Future<void> deleteTrainingGroup(String id, String archiverId) async {
    final conn = await _db.connection;
    await conn.execute(
      Sql.named('''
        UPDATE training_groups
        SET archived_at = NOW(), archived_by = @archiverId
        WHERE id = @id
      '''),
      parameters: {'id': id, 'archiverId': archiverId},
    );
  }

  Future<List<TrainingGroupType>> getAllTrainingGroupTypes() async {
    final conn = await _db.connection;
    final results = await conn.execute('SELECT * FROM training_group_types ORDER BY id');
    return results.map((row) => TrainingGroupType.fromJson(row.toColumnMap())).toList();
  }

  // --- Analytic Group Methods ---

  // --- Analytic Group Methods ---

  Future<List<AnalyticGroup>> getAllAnalyticGroups({bool? isArchived}) async {
    final conn = await _db.connection;
    final List<String> whereClauses = [];
    final Map<String, dynamic> parameters = {};

    if (isArchived != null) {
      if (isArchived) {
        whereClauses.add('archived_at IS NOT NULL');
      } else {
        whereClauses.add('archived_at IS NULL');
      }
    } else {
      // By default, only show non-archived groups if isArchived is not specified
      whereClauses.add('archived_at IS NULL');
    }

    final whereString = whereClauses.isNotEmpty ? 'WHERE ${whereClauses.join(' AND ')}' : '';
    final results = await conn.execute(
      Sql.named('SELECT * FROM analytic_groups $whereString'),
      parameters: parameters,
    );
    return results.map((row) {
      final map = row.toColumnMap();
      print('--- Raw Analytic Group DB Row Map ---');
      print(map);
      print('------------------------------------');
      return AnalyticGroup.fromJson(map);
    }).toList();
  }

  Future<AnalyticGroup?> getAnalyticGroupById(String id) async {
    final conn = await _db.connection;
    final results = await conn.execute(
      Sql.named('SELECT * FROM analytic_groups WHERE id = @id AND archived_at IS NULL'),
      parameters: {'id': id},
    );
    if (results.isEmpty) return null;
    return AnalyticGroup.fromJson(results.first.toColumnMap());
  }

  Future<AnalyticGroup> createAnalyticGroup(AnalyticGroup group, String creatorId) async {
    final conn = await _db.connection;
    final result = await conn.execute(
      Sql.named('''
        INSERT INTO analytic_groups (
          name, description, type, is_auto_update, conditions, metadata,
          client_ids_cache, created_by, updated_by
        )
        VALUES (
          @name, @description, @type, @is_auto_update, @conditions, @metadata,
          @client_ids_cache, @created_by, @updated_by
        )
        RETURNING *
      '''),
      parameters: {
        'name': group.name,
        'description': group.description,
        'type': group.type.index,
        'is_auto_update': group.isAutoUpdate,
        'conditions': group.conditions.map((e) => e.toJson()).toList(),
        'metadata': group.metadata,
        'client_ids_cache': group.clientIds,
        'created_by': creatorId,
        'updated_by': creatorId,
      },
    );
    return AnalyticGroup.fromJson(result.first.toColumnMap());
  }

  Future<AnalyticGroup> updateAnalyticGroup(AnalyticGroup group, String updaterId) async {
    final conn = await _db.connection;
    final result = await conn.execute(
      Sql.named('''
        UPDATE analytic_groups
        SET
          name = @name,
          description = @description,
          type = @type,
          is_auto_update = @is_auto_update,
          conditions = @conditions,
          metadata = @metadata,
          updated_by = @updaterId,
          updated_at = NOW()
        WHERE id = @id
        RETURNING *
      '''),
      parameters: {
        'id': group.id,
        'name': group.name,
        'description': group.description,
        'type': group.type.index,
        'is_auto_update': group.isAutoUpdate,
        'conditions': group.conditions.map((e) => e.toJson()).toList(),
        'metadata': group.metadata,
        'updaterId': updaterId,
      },
    );
    return AnalyticGroup.fromJson(result.first.toColumnMap());
  }

  Future<void> deleteAnalyticGroup(String id, String archiverId) async {
    final conn = await _db.connection;
    await conn.execute(
      Sql.named('''
        UPDATE analytic_groups
        SET archived_at = NOW(), archived_by = @archiverId
        WHERE id = @id
      '''),
      parameters: {'id': id, 'archiverId': archiverId},
    );
  }

  // --- Training Group Member Methods ---

  // --- Training Group Member Methods ---

  Future<List<String>> getTrainingGroupMembers(String groupId) async {
    final conn = await _db.connection;
    final results = await conn.execute(
      Sql.named('SELECT user_id FROM training_group_members WHERE training_group_id = @groupId'),
      parameters: {'groupId': groupId},
    );
    return results.map((row) => row[0] as String).toList();
  }

  Future<void> addTrainingGroupMember(String groupId, String userId, String addedById) async {
    final conn = await _db.connection;
    await conn.execute(
      Sql.named('''
        INSERT INTO training_group_members (training_group_id, user_id, added_by)
        VALUES (@groupId, @userId, @addedBy)
        ON CONFLICT (training_group_id, user_id) DO NOTHING
      '''),
      parameters: {'groupId': groupId, 'userId': userId, 'addedBy': addedById},
    );
  }

  Future<void> removeTrainingGroupMember(String groupId, String userId) async {
    final conn = await _db.connection;
    await conn.execute(
      Sql.named('''
        DELETE FROM training_group_members
        WHERE training_group_id = @groupId AND user_id = @userId
      '''),
      parameters: {'groupId': groupId, 'userId': userId},
    );
  }

  // --- Group Movement Methods ---

  // --- Replacement Methods ---

  Future<void> replaceStaff({
    required String groupId,
    required String oldStaffId,
    required String newStaffId,
    required String role,
    required String reason,
    required String initiatorId,
  }) async {
    final conn = await _db.connection;
    return conn.runTx((session) async {
      // 1. Update the group
      final column = role == 'trainer' ? 'primary_trainer_id' : 
                     role == 'instructor' ? 'primary_instructor_id' : 
                     'responsible_manager_id';
      
      await session.execute(
        Sql.named('UPDATE training_groups SET $column = @newStaffId WHERE id = @groupId'),
        parameters: {'newStaffId': newStaffId, 'groupId': groupId},
      );

      // 2. Log the replacement in training_group_replacement_employees
      await session.execute(
        Sql.named(r'''
          INSERT INTO training_group_replacement_employees (
            group_id, old_employee_id, new_employee_id, date, reason, initiator_id
          )
          VALUES (
            @groupId, @oldEmployeeId, @newEmployeeId, NOW(), @reason, @initiatorId
          )
        '''),
        parameters: {
          'groupId': groupId,
          'oldEmployeeId': oldStaffId,
          'newEmployeeId': newStaffId,
          'reason': reason,
          'initiatorId': initiatorId,
        },
      );
    });
  }

  Future<void> removeStaff({
    required String groupId,
    required String staffId,
    required String role,
    required String reason,
    required String initiatorId,
  }) async {
    final conn = await _db.connection;
    return conn.runTx((session) async {
      // 1. Update the group (set to null)
      final column = role == 'trainer' ? 'primary_trainer_id' : 
                     role == 'instructor' ? 'primary_instructor_id' : 
                     'responsible_manager_id';
      
      await session.execute(
        Sql.named('UPDATE training_groups SET $column = NULL WHERE id = @groupId'),
        parameters: {'groupId': groupId},
      );

      // 2. Log the removal in training_group_users_remove
      await session.execute(
        Sql.named(r'''
          INSERT INTO training_group_users_remove (
            group_id, user_id, user_role, removed_at, reason, initiator_id
          )
          VALUES (
            @groupId, @userId, @userRole, NOW(), @reason, @initiatorId
          )
        '''),
        parameters: {
          'groupId': groupId,
          'userId': staffId,
          'userRole': role,
          'reason': reason,
          'initiatorId': initiatorId,
        },
      );
    });
  }

  Future<List<TrainingGroupReplacementEmployee>> getReplacementsForGroup(String groupId) async {
    final conn = await _db.connection;
    final results = await conn.execute(
      Sql.named('''
        SELECT * FROM training_group_replacement_employees
        WHERE group_id = @groupId AND new_employee_id IS NOT NULL
        ORDER BY date DESC
      '''),
      parameters: {'groupId': groupId},
    );
    return results
        .map((row) => TrainingGroupReplacementEmployee.fromJson(row.toColumnMap()))
        .toList();
  }

  Future<List<TrainingGroupUserRemove>> getRemovalsForGroup(String groupId) async {
    final conn = await _db.connection;
    final results = await conn.execute(
      Sql.named('''
        SELECT * FROM training_group_users_remove
        WHERE group_id = @groupId
        ORDER BY removed_at DESC
      '''),
      parameters: {'groupId': groupId},
    );
    return results
        .map((row) => TrainingGroupUserRemove.fromJson(row.toColumnMap()))
        .toList();
  }

  Future<List<GroupMovement>> getMovementsForUser(String userId) async {
    final conn = await _db.connection;
    final results = await conn.execute(
      Sql.named('''
        SELECT * FROM training_group_member_movements
        WHERE user_id = @userId
          AND NOT (from_group_id IS NOT NULL AND to_group_id IS NULL)
        ORDER BY movement_date DESC
      '''),
      parameters: {'userId': userId},
    );
    return results
        .map((row) => GroupMovement.fromJson(row.toColumnMap()))
        .toList();
  }

  Future<List<GroupMovement>> getMovementsForGroup(String groupId) async {
    final conn = await _db.connection;
    final results = await conn.execute(
      Sql.named('''
        SELECT * FROM training_group_member_movements
        WHERE (from_group_id = @groupId OR to_group_id = @groupId)
          AND NOT (from_group_id IS NOT NULL AND to_group_id IS NULL)
        ORDER BY movement_date DESC
      '''),
      parameters: {'groupId': groupId},
    );
    return results
        .map((row) => GroupMovement.fromJson(row.toColumnMap()))
        .toList();
  }

  Future<void> moveClient({
    required String clientId,
    String? fromGroupId,
    String? toGroupId,
    required String reason,
    required String movedByUserId,
  }) async {
    final conn = await _db.connection;
    return conn.runTx((session) async {
      // 1. Validation: Check capacity of the target group
      if (toGroupId != null) {
        final toGroupResult = await session.execute(
          Sql.named('SELECT max_participants FROM training_groups WHERE id = @id'),
          parameters: {'id': toGroupId},
        );

        if (toGroupResult.isEmpty) {
          throw ArgumentError('Target group not found.');
        }
        final maxParticipants = toGroupResult.first.toColumnMap()['max_participants'] as int;

        final currentMembersResult = await session.execute(
          Sql.named('SELECT COUNT(*) as count FROM training_group_members WHERE training_group_id = @id'),
          parameters: {'id': toGroupId},
        );
        final currentParticipants = currentMembersResult.first.toColumnMap()['count'] as int;

        if (currentParticipants >= maxParticipants) {
          throw StateError('The target group is already full.');
        }
      }

      // 2. Update membership
      if (fromGroupId != null) {
        await session.execute(
          Sql.named('DELETE FROM training_group_members WHERE training_group_id = @fromGroupId AND user_id = @clientId'),
          parameters: {'fromGroupId': fromGroupId, 'clientId': clientId},
        );
      }
      if (toGroupId != null) {
        await session.execute(
          Sql.named('INSERT INTO training_group_members (training_group_id, user_id, added_by) VALUES (@toGroupId, @clientId, @addedBy)'),
          parameters: {'toGroupId': toGroupId, 'clientId': clientId, 'addedBy': movedByUserId},
        );
      }

      // 3. Log the movement or removal
      if (fromGroupId != null && toGroupId == null) {
        await session.execute(
          Sql.named(r'''
            INSERT INTO training_group_users_remove (
              group_id, user_id, user_role, removed_at, reason, initiator_id
            )
            VALUES (
              @groupId, @userId, 'client', NOW(), @reason, @initiatorId
            )
          '''),
          parameters: {
            'groupId': fromGroupId,
            'userId': clientId,
            'reason': reason,
            'initiatorId': movedByUserId,
          },
        );
      } else {
        await session.execute(
          Sql.named(r'''
            INSERT INTO training_group_member_movements (
              user_id, from_group_id, to_group_id,
              movement_date, reason, moved_by_user_id
            )
            VALUES (
              @userId, @fromGroupId, @toGroupId,
              @movementDate, @reason, @movedByUserId
            )
          '''),
          parameters: {
            'userId': clientId,
            'fromGroupId': fromGroupId,
            'toGroupId': toGroupId,
            'movementDate': DateTime.now().toUtc(),
            'reason': reason,
            'movedByUserId': movedByUserId,
          },
        );
      }
    });
  }

  // --- Group Schedule Slot Methods ---

  Future<List<GroupSchedule>> getGroupSchedules(String groupId) async {
    final conn = await _db.connection;
    final results = await conn.execute(
      Sql.named('SELECT * FROM group_schedule_slots WHERE group_id = @groupId AND is_active = TRUE'),
      parameters: {'groupId': groupId},
    );
    return results.map((row) => GroupSchedule.fromJson(row.toColumnMap())).toList();
  }

  Future<GroupSchedule> createGroupSchedule(GroupSchedule slot) async {
    final conn = await _db.connection;
    final result = await conn.execute(
      Sql.named('''
        INSERT INTO group_schedule_slots (group_id, day_of_week, start_time, end_time, is_active)
        VALUES (@groupId, @dayOfWeek, @startTime, @endTime, @isActive)
        RETURNING *
      '''),
      parameters: {
        'groupId': slot.groupId,
        'dayOfWeek': slot.dayOfWeek,
        'startTime': slot.startTime.toJson(),
        'endTime': slot.endTime.toJson(),
        'isActive': slot.isActive,
      },
    );
    return GroupSchedule.fromJson(result.first.toColumnMap());
  }

  Future<GroupSchedule> updateGroupSchedule(GroupSchedule slot) async {
    final conn = await _db.connection;
    final result = await conn.execute(
      Sql.named('''
        UPDATE group_schedule_slots
        SET
          day_of_week = @dayOfWeek,
          start_time = @startTime,
          end_time = @endTime,
          is_active = @isActive
        WHERE id = @id
        RETURNING *
      '''),
      parameters: {
        'id': slot.id,
        'dayOfWeek': slot.dayOfWeek,
        'startTime': slot.startTime.toJson(),
        'endTime': slot.endTime.toJson(),
        'isActive': slot.isActive,
      },
    );
    return GroupSchedule.fromJson(result.first.toColumnMap());
  }

  Future<void> deleteGroupSchedule(String id) async {
    final conn = await _db.connection;
    await conn.execute(
      Sql.named('DELETE FROM group_schedule_slots WHERE id = @id'),
      parameters: {'id': id},
    );
  }
}
