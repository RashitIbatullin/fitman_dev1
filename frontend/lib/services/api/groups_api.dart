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
  
  // --- Training Group Type Methods ---

  Future<List<TrainingGroupType>> getAllTrainingGroupTypes() async {
    final data = await get('/api/training_group_types');
    return (data as List).map((json) => TrainingGroupType.fromJson(json)).toList();
  }
}
