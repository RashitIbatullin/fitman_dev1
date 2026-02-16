import 'package:postgres/postgres.dart';
import '../../../config/database.dart';
import '../models/analytic_group.model.dart';
import '../models/group_schedule.model.dart';
import '../models/training_group.model.dart';
import '../models/training_group_type.model.dart';

class GroupRepository {
  final Database _db;

  GroupRepository(this._db);

  // --- Training Group Methods ---

  Future<List<TrainingGroup>> getAllTrainingGroups({
    String? searchQuery,
    int? groupTypeId,
    bool? isActive,
    bool? isArchived,
    int? trainerId,
    int? instructorId,
    int? managerId,
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

  Future<TrainingGroup?> getTrainingGroupById(int id) async {
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

  Future<TrainingGroup> createTrainingGroup(TrainingGroup group, int creatorId) async {
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

  Future<TrainingGroup> updateTrainingGroup(TrainingGroup group, int updaterId) async {
    final conn = await _db.connection;
    final result = await conn.execute(
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
    return TrainingGroup.fromJson(result.first.toColumnMap());
  }

  Future<void> deleteTrainingGroup(int id, int archiverId) async {
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

  Future<AnalyticGroup?> getAnalyticGroupById(int id) async {
    final conn = await _db.connection;
    final results = await conn.execute(
      Sql.named('SELECT * FROM analytic_groups WHERE id = @id AND archived_at IS NULL'),
      parameters: {'id': id},
    );
    if (results.isEmpty) return null;
    return AnalyticGroup.fromJson(results.first.toColumnMap());
  }

  Future<AnalyticGroup> createAnalyticGroup(AnalyticGroup group, int creatorId) async {
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

  Future<AnalyticGroup> updateAnalyticGroup(AnalyticGroup group, int updaterId) async {
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

  Future<void> deleteAnalyticGroup(int id, int archiverId) async {
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

  Future<List<int>> getTrainingGroupMembers(int groupId) async {
    final conn = await _db.connection;
    final results = await conn.execute(
      Sql.named('SELECT user_id FROM training_group_members WHERE training_group_id = @groupId'),
      parameters: {'groupId': groupId},
    );
    return results.map((row) => row[0] as int).toList();
  }

  Future<void> addTrainingGroupMember(int groupId, int userId, int addedById) async {
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

  Future<void> removeTrainingGroupMember(int groupId, int userId) async {
    final conn = await _db.connection;
    await conn.execute(
      Sql.named('''
        DELETE FROM training_group_members
        WHERE training_group_id = @groupId AND user_id = @userId
      '''),
      parameters: {'groupId': groupId, 'userId': userId},
    );
  }

  // --- Group Schedule Slot Methods ---

  Future<List<GroupSchedule>> getGroupSchedules(int groupId) async {
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

  Future<void> deleteGroupSchedule(int id) async {
    final conn = await _db.connection;
    await conn.execute(
      Sql.named('DELETE FROM group_schedule_slots WHERE id = @id'),
      parameters: {'id': id},
    );
  }
}
