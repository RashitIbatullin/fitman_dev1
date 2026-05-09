import 'package:postgres/postgres.dart';

class GroupSeeder {
  GroupSeeder(this._connection);
  final Connection _connection;

  Future<String> createTrainingGroup({
    required String name,
    required String description,
    required String trainingGroupTypeId,
    required String primaryTrainerId,
    String? primaryInstructorId,
    String? responsibleManagerId,
    int maxParticipants = 15,
    required String createdBy,
  }) async {
    final result = await _connection.execute(Sql.named(r'''
      INSERT INTO training_groups (name, description, training_group_type_id, primary_trainer_id, primary_instructor_id, responsible_manager_id, max_participants, start_date, created_by, updated_by)
      VALUES (@name, @description, @typeId, @primary_trainer_id, @primary_instructor_id, @responsible_manager_id, @max_participants, @start_date, @created_by, @created_by)
      RETURNING id;
    '''), parameters: {
      'name': name,
      'description': description,
      'typeId': trainingGroupTypeId,
      'primary_trainer_id': primaryTrainerId,
      'primary_instructor_id': primaryInstructorId,
      'responsible_manager_id': responsibleManagerId,
      'max_participants': maxParticipants,
      'start_date': DateTime.now(),
      'created_by': createdBy,
    });
    return result.first[0].toString();
  }

  Future<void> addMemberToTrainingGroup({
    required String groupId,
    required String userId,
    required String addedBy,
  }) async {
    await _connection.execute(Sql.named(r'''
      INSERT INTO training_group_members (training_group_id, user_id, added_by)
      VALUES (@group_id, @user_id, @added_by)
      ON CONFLICT (training_group_id, user_id) DO NOTHING;
    '''), parameters: {
      'group_id': groupId,
      'user_id': userId,
      'added_by': addedBy,
    });
  }

  Future<void> createGroupSchedule({
    required String groupId,
    required int dayOfWeek,
    required String startTime,
    required String endTime,
  }) async {
    await _connection.execute(Sql.named(r'''
      INSERT INTO group_schedule_slots (group_id, day_of_week, start_time, end_time)
      VALUES (@group_id, @day_of_week, @start_time, @end_time);
    '''), parameters: {
      'group_id': groupId,
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
    });
  }
}
