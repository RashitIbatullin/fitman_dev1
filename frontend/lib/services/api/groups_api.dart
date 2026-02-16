import '../../modules/groups/models/analytic_group.model.dart';
import '../../modules/groups/models/group_schedule.model.dart';
import '../../modules/groups/models/training_group.model.dart';
import '../../modules/groups/models/training_group_type.model.dart';
import 'base_api.dart';

/// Service class for group-related APIs (Training, Analytic, Schedules, Members).
class GroupsApiService extends BaseApiService {
  GroupsApiService({super.client});

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
    final queryParams = <String, String>{};
    if (searchQuery != null && searchQuery.isNotEmpty) queryParams['q'] = searchQuery;
    if (groupTypeId != null) queryParams['groupTypeId'] = groupTypeId.toString();
    if (isActive != null) queryParams['isActive'] = isActive.toString();
    if (isArchived != null) queryParams['isArchived'] = isArchived.toString();
    if (trainerId != null) queryParams['trainerId'] = trainerId.toString();
    if (instructorId != null) queryParams['instructorId'] = instructorId.toString();
    if (managerId != null) queryParams['managerId'] = managerId.toString();
    
    final data = await get('/api/training_groups', queryParams: queryParams.isNotEmpty ? queryParams : null);
    return (data as List).map((json) => TrainingGroup.fromJson(json)).toList();
  }

  Future<TrainingGroup> getTrainingGroupById(int id) async {
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

  Future<void> deleteTrainingGroup(int id) async {
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

  Future<AnalyticGroup> getAnalyticGroupById(int id) async {
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

  Future<void> deleteAnalyticGroup(int id) async {
    await delete('/api/analytic_groups/$id');
  }

  // --- Group Schedule Methods ---

  Future<List<GroupSchedule>> getGroupSchedules(int groupId) async {
    final data = await get('/api/group_schedules/$groupId');
    return (data as List).map((json) => GroupSchedule.fromJson(json)).toList();
  }

  Future<GroupSchedule> createGroupSchedule(int groupId, GroupSchedule slot) async {
    final data = await post('/api/group_schedules/$groupId', body: slot.toJson());
    return GroupSchedule.fromJson(data);
  }

  Future<GroupSchedule> updateGroupSchedule(GroupSchedule slot) async {
    final data = await put('/api/group_schedules/${slot.id}', body: slot.toJson());
    return GroupSchedule.fromJson(data);
  }

  Future<void> deleteGroupSchedule(int id) async {
    await delete('/api/group_schedules/$id');
  }

  // --- Training Group Member Methods ---

  Future<List<int>> getTrainingGroupMembers(int groupId) async {
    final data = await get('/api/training_groups/$groupId/members');
    return (data as List).cast<int>().toList();
  }

  Future<void> addTrainingGroupMember(int groupId, int userId) async {
    await post('/api/training_groups/$groupId/members', body: {'userId': userId});
  }

  Future<void> removeTrainingGroupMember(int groupId, int userId) async {
    await delete('/api/training_groups/$groupId/members/$userId');
  }
  
  // --- Training Group Type Methods ---

  Future<List<TrainingGroupType>> getAllTrainingGroupTypes() async {
    final data = await get('/api/training_group_types');
    return (data as List).map((json) => TrainingGroupType.fromJson(json)).toList();
  }
}
