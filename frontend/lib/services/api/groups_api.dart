import 'package:fitman_common/modules/groups/training_group_replacement_employee.model.dart';
import 'package:fitman_common/modules/groups/training_group_user_remove.model.dart';
import 'package:fitman_common/modules/groups/analytic_group.model.dart';
import 'package:fitman_common/modules/groups/group_schedule.model.dart';
import 'package:fitman_common/modules/groups/training_group.model.dart';
import 'package:fitman_common/modules/groups/training_group_type.model.dart';
import 'package:fitman_common/modules/groups/group_movement.model.dart';
import 'base_api.dart';

/// Service class for group-related APIs (Training, Analytic, Schedules, Members).
class GroupsApiService extends BaseApiService {
  GroupsApiService({super.client});

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
    final queryParams = <String, String>{};
    if (searchQuery != null && searchQuery.isNotEmpty) queryParams['q'] = searchQuery;
    if (groupTypeId != null) queryParams['groupTypeId'] = groupTypeId;
    if (isActive != null) queryParams['isActive'] = isActive.toString();
    if (isArchived != null) queryParams['isArchived'] = isArchived.toString();
    if (trainerId != null) queryParams['trainerId'] = trainerId;
    if (instructorId != null) queryParams['instructorId'] = instructorId;
    if (managerId != null) queryParams['managerId'] = managerId;
    
    final data = await get('/api/training_groups', queryParams: queryParams.isNotEmpty ? queryParams : null);
    return (data as List).map((json) => TrainingGroup.fromJson(json)).toList();
  }

  Future<TrainingGroup> getTrainingGroupById(String id) async {
    final data = await get('/api/training_groups/$id');
    return TrainingGroup.fromJson(data);
  }

  Future<TrainingGroup> createTrainingGroup(TrainingGroup group) async {
    final data = await post('/api/training_groups', body: group.toJson());
    return TrainingGroup.fromJson(data);
  }

  Future<TrainingGroup> updateTrainingGroup(TrainingGroup group) async {
    final data = await put('/api/training_groups/${group.id}', body: group.toJson());
    return TrainingGroup.fromJson(data);
  }

  Future<void> deleteTrainingGroup(String id) async {
    await delete('/api/training_groups/$id');
  }

  // --- Analytic Group Methods ---

  Future<List<AnalyticGroup>> getAllAnalyticGroups({bool? isActive, bool? isArchived}) async {
    final queryParams = <String, String>{};
    if (isActive != null) queryParams['isActive'] = isActive.toString();
    if (isArchived != null) queryParams['isArchived'] = isArchived.toString();

    final data = await get('/api/analytic_groups', queryParams: queryParams.isNotEmpty ? queryParams : null);
    return (data as List).map((json) => AnalyticGroup.fromJson(json)).toList();
  }

  Future<AnalyticGroup> getAnalyticGroupById(String id) async {
    final data = await get('/api/analytic_groups/$id');
    return AnalyticGroup.fromJson(data);
  }

  Future<AnalyticGroup> createAnalyticGroup(AnalyticGroup group) async {
    final data = await post('/api/analytic_groups', body: group.toJson());
    return AnalyticGroup.fromJson(data);
  }

  Future<AnalyticGroup> updateAnalyticGroup(AnalyticGroup group) async {
    final data = await put('/api/analytic_groups/${group.id}', body: group.toJson());
    return AnalyticGroup.fromJson(data);
  }

  Future<void> deleteAnalyticGroup(String id) async {
    await delete('/api/analytic_groups/$id');
  }

  // --- Group Schedule Methods ---

  Future<List<GroupSchedule>> getGroupSchedules(String groupId) async {
    final data = await get('/api/group_schedules/$groupId');
    return (data as List).map((json) => GroupSchedule.fromJson(json)).toList();
  }

  Future<GroupSchedule> createGroupSchedule(String groupId, GroupSchedule slot) async {
    final data = await post('/api/group_schedules/$groupId', body: slot.toJson());
    return GroupSchedule.fromJson(data);
  }

  Future<GroupSchedule> updateGroupSchedule(GroupSchedule slot) async {
    final data = await put('/api/group_schedules/${slot.id}', body: slot.toJson());
    return GroupSchedule.fromJson(data);
  }

  Future<void> deleteGroupSchedule(String id) async {
    await delete('/api/group_schedules/$id');
  }

  // --- Training Group Member Methods ---

  Future<List<String>> getTrainingGroupMembers(String groupId) async {
    final data = await get('/api/training_groups/$groupId/members');
    return (data as List).cast<String>().toList();
  }

  Future<void> addTrainingGroupMember(String groupId, String userId) async {
    await post('/api/training_groups/$groupId/members', body: {'userId': userId});
  }

  Future<void> removeTrainingGroupMember(String groupId, String userId) async {
    await delete('/api/training_groups/$groupId/members/$userId');
  }
  
  Future<List<TrainingGroupReplacementEmployee>> getReplacementsForGroup(String groupId) async {
    final data = await get('/api/training_groups/$groupId/replacements');
    return (data as List).map((json) => TrainingGroupReplacementEmployee.fromJson(json)).toList();
  }

  Future<List<TrainingGroupUserRemove>> getRemovalsForGroup(String groupId) async {
    final data = await get('/api/training_groups/$groupId/removals');
    return (data as List).map((json) => TrainingGroupUserRemove.fromJson(json)).toList();
  }

  Future<void> replaceStaff({
    required String groupId,
    required String oldStaffId,
    required String newStaffId,
    required String role,
    required String reason,
  }) async {
    await post(
      '/api/training_groups/replace-staff',
      body: {
        'groupId': groupId,
        'oldStaffId': oldStaffId,
        'newStaffId': newStaffId,
        'role': role,
        'reason': reason,
      },
    );
  }

  Future<void> removeStaff({
    required String groupId,
    required String staffId,
    required String role,
    required String reason,
  }) async {
    await post(
      '/api/training_groups/remove-staff',
      body: {
        'groupId': groupId,
        'staffId': staffId,
        'role': role,
        'reason': reason,
      },
    );
  }

  // --- Training Group Type Methods ---

  Future<List<TrainingGroupType>> getAllTrainingGroupTypes() async {
    final data = await get('/api/training_group_types');
    return (data as List).map((json) => TrainingGroupType.fromJson(json)).toList();
  }

  // --- Group Movement Methods ---

  Future<void> moveClient({
    required String clientId,
    String? fromGroupId,
    String? toGroupId,
    required String reason,
  }) async {
    await post(
      '/api/training_groups/move-client',
      body: {
        'clientId': clientId,
        'fromGroupId': fromGroupId,
        'toGroupId': toGroupId,
        'reason': reason,
      },
    );
  }

  Future<List<GroupMovement>> getGroupMovements(String groupId) async {
    final data = await get('/api/training_groups/$groupId/movements');
    return (data as List).map((json) => GroupMovement.fromJson(json)).toList();
  }

  Future<List<GroupMovement>> getUserMovements(String userId) async {
    final data = await get('/api/training_groups/user/$userId/movements');
    return (data as List).map((json) => GroupMovement.fromJson(json)).toList();
  }
}
