import 'package:fitman_common/fitman_common.dart';
import 'package:fitman_common/modules/chat/chat_models.dart';

import 'api/admin_api.dart';
import 'api/auth_api.dart';
import 'api/base_api.dart';
import 'api/catalogs_api.dart';
import 'api/chat_api.dart';
import 'api/client_api.dart';
import 'api/groups_api.dart';
import 'api/infrastructure_api.dart';
import 'api/maintenance_api.dart';
import 'api/instructor_api.dart';
import 'api/manager_api.dart';
import 'api/recommendation_api.dart';
import 'api/room_schedule_api.dart';
import 'api/schedule_api.dart';
import 'api/support_staff_api.dart';
import 'api/employee_api.dart';
import 'package:fitman_common/modules/support_staff/competency.model.dart';
import 'package:fitman_common/modules/support_staff/support_staff.model.dart';
import 'package:fitman_common/modules/groups/training_group.model.dart';
import 'package:fitman_common/modules/groups/analytic_group.model.dart';
import 'package:fitman_common/modules/groups/group_schedule.model.dart';
import 'package:fitman_common/modules/groups/training_group_type.model.dart';
import 'package:fitman_common/modules/rooms/room_schedule.model.dart';


class ApiService {
  // Instantiate all the modular services
  static final AuthApiService _authApi = AuthApiService();
  static final InfrastructureApiService _infrastructureApi = InfrastructureApiService();
  static final MaintenanceApiService _maintenanceApi = MaintenanceApiService();
  static final GroupsApiService _groupsApi = GroupsApiService();
  static final ChatApiService _chatApi = ChatApiService();
  static final ManagerApiService _managerApi = ManagerApiService();
  static final InstructorApiService _instructorApi = InstructorApiService();
  static final ClientApiService _clientApi = ClientApiService();
  static final CatalogsApiService _catalogsApi = CatalogsApiService();
  static final ScheduleApiService _scheduleApi = ScheduleApiService();
  static final AdminApiService _adminApi = AdminApiService();
  static final RecommendationApiService _recommendationApi = RecommendationApiService();
  static final SupportStaffApi _supportStaffApi = SupportStaffApi();
  static final RoomScheduleApiService _roomScheduleApi = RoomScheduleApiService();
  static final EmployeeApiService _employeeApi = EmployeeApiService();


  // --- Token and Session Management ---
  static Future<void> init() => BaseApiService.init();
  static Future<void> saveToken(String token) => BaseApiService.saveToken(token);
  static Future<void> clearToken() => BaseApiService.clearToken();
  static String? get currentToken => BaseApiService.currentToken;
  static String get baseUrl => BaseApiService.baseUrl;

  // --- Auth & User Methods ---
  static Future<AuthResponse> login(String phone, String password) =>
      _authApi.login(phone, password);

  static Future<AuthResponse> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required List<String> roles,
    String? phone,
    String? gender,
    DateTime? dateOfBirth,
  }) =>
      _authApi.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        roles: roles,
        phone: phone,
        gender: gender,
        dateOfBirth: dateOfBirth,
      );

  static Future<User> checkTokenAndGetUser() => _authApi.checkTokenAndGetUser();
  static Future<User> createUser(CreateUserRequest request) => _authApi.createUser(request);
  static Future<User> updateUser(UpdateUserRequest request) => _authApi.updateUser(request);
  static Future<List<User>> getUsers({String? role, int? offset, int? limit, bool? isArchived}) =>
      _authApi.getUsers(role: role, offset: offset, limit: limit, isArchived: isArchived);
  static Future<User> getUserById(String userId) => _authApi.getUserById(userId);
  static Future<List<Role>> getAllRoles() => _authApi.getAllRoles();
  static Future<List<Role>> getUserRoles(String userId) => _authApi.getUserRoles(userId);
  static Future<void> updateUserRoles(String userId, List<String> roleNames) =>
      _authApi.updateUserRoles(userId, roleNames);
  static Future<void> archiveUser(String userId, {String? reason}) =>
      _authApi.archiveUser(userId, reason: reason);
  static Future<Map<String, dynamic>> uploadAvatar(List<int> photoBytes, String fileName, String userId) =>
      _authApi.uploadAvatar(photoBytes, fileName, userId);
  static Future<void> resetUserPassword(String userId, String newPassword) =>
      _authApi.resetUserPassword(userId, newPassword);

  // --- Employee Competency Methods ---
  static Future<List<Competency>> getEmployeeCompetencies(String userId) =>
      _employeeApi.getCompetencies(userId);
  static Future<Competency> addEmployeeCompetency(String userId, Competency competency) =>
      _employeeApi.addCompetency(userId, competency);
  static Future<void> deleteEmployeeCompetency(String userId, String competencyId) =>
      _employeeApi.deleteCompetency(userId, competencyId);

  // --- Infrastructure Methods ---
  static Future<List<Room>> getAllRooms({String? buildingId, int? roomType, bool? isActive, bool? isArchived}) =>
      _infrastructureApi.getAllRooms(
          buildingId: buildingId, roomType: roomType, isActive: isActive, isArchived: isArchived);
  static Future<Room> getRoomById(String id) => _infrastructureApi.getRoomById(id);
  static Future<Room> createRoom(Room room) => _infrastructureApi.createRoom(room);
  static Future<Room> updateRoom(String id, Room room) => _infrastructureApi.updateRoom(id, room);
  static Future<void> deleteRoom(String id) => _infrastructureApi.deleteRoom(id);

  static Future<List<Building>> getAllBuildings({bool? isArchived}) =>
      _infrastructureApi.getAllBuildings(isArchived: isArchived);
  static Future<Building> getBuildingById(String id) => _infrastructureApi.getBuildingById(id);
  static Future<Building> createBuilding(Building building) => _infrastructureApi.createBuilding(building);
  static Future<Building> updateBuilding(String id, Building building) =>
      _infrastructureApi.updateBuilding(id, building);
  static Future<void> deleteBuilding(String id) => _infrastructureApi.deleteBuilding(id);

  static Future<List<EquipmentItem>> getAllEquipmentItems(
          {String? roomId, bool? isArchived}) =>
      _infrastructureApi.getAllEquipmentItems(
          roomId: roomId, isArchived: isArchived);
  static Future<EquipmentItem> getEquipmentItemById(String id) =>
      _infrastructureApi.getEquipmentItemById(id);
  static Future<void> archiveEquipmentItem(String id, String reason) =>
      _infrastructureApi.archiveEquipmentItem(id, reason);
  static Future<void> unarchiveEquipmentItem(String id) =>
      _infrastructureApi.unarchiveEquipmentItem(id);

  static Future<EquipmentItem> createEquipmentItem(EquipmentItem equipmentItem) =>
      _infrastructureApi.createEquipmentItem(equipmentItem);
  static Future<EquipmentItem> updateEquipmentItem(String id, EquipmentItem equipmentItem) =>
      _infrastructureApi.updateEquipmentItem(id, equipmentItem);

  static Future<List<EquipmentType>> getAllEquipmentTypes(
          {EquipmentCategory? category, bool? isArchived}) =>
      _infrastructureApi.getAllEquipmentTypes(
          category: category, isArchived: isArchived);
  static Future<EquipmentType> getEquipmentTypeById(String id) =>
      _infrastructureApi.getEquipmentTypeById(id);
  static Future<EquipmentType> createEquipmentType(
          EquipmentType equipmentType) =>
      _infrastructureApi.createEquipmentType(equipmentType);
  static Future<EquipmentType> updateEquipmentType(
          String id, EquipmentType equipmentType) =>
      _infrastructureApi.updateEquipmentType(id, equipmentType);
  static Future<void> deleteEquipmentType(String id) =>
      _infrastructureApi.deleteEquipmentType(id);
  static Future<void> archiveEquipmentType(String id, String reason) =>
      _infrastructureApi.archiveEquipmentType(id, reason);
  static Future<void> unarchiveEquipmentType(String id) =>
      _infrastructureApi.unarchiveEquipmentType(id);

  static Future<String> uploadRoomPhoto({
    required String roomId,
    required List<int> photoBytes,
    required String fileName,
  }) => _infrastructureApi.uploadRoomPhoto(
    roomId: roomId,
    photoBytes: photoBytes,
    fileName: fileName,
  );

  // ADDED METHOD
  static Future<void> removeRoomPhoto({
    required String roomId,
    required String photoUrl,
  }) => _infrastructureApi.removeRoomPhoto(
    roomId: roomId,
    photoUrl: photoUrl,
  );

  static Future<String> uploadEquipmentPhoto({
    required String equipmentId,
    required List<int> photoBytes,
    required String fileName,
  }) => _infrastructureApi.uploadEquipmentPhoto(
    equipmentId: equipmentId,
    photoBytes: photoBytes,
    fileName: fileName,
  );

  static Future<void> removeEquipmentPhoto({
    required String equipmentId,
    required String photoUrl,
  }) => _infrastructureApi.removeEquipmentPhoto(
    equipmentId: equipmentId,
    photoUrl: photoUrl,
  );

  // --- Room Schedule Methods ---
  static Future<List<RoomSchedule>> getRoomSchedules(String roomId) =>
      _roomScheduleApi.getRoomSchedules(roomId);
  static Future<void> updateRoomSchedules(String roomId, List<RoomSchedule> schedules) =>
      _roomScheduleApi.updateRoomSchedules(roomId, schedules);

  // --- Maintenance History Methods ---
  static Future<List<EquipmentMaintenanceHistory>> getAllMaintenanceHistory() =>
      _maintenanceApi.getAllMaintenanceHistory();
  static Future<List<EquipmentMaintenanceHistory>> getMaintenanceHistory(String itemId, {bool includeArchived = false}) =>
      _maintenanceApi.getMaintenanceHistory(itemId, includeArchived: includeArchived);
  static Future<EquipmentMaintenanceHistory> createMaintenanceHistory(
          EquipmentMaintenanceHistory history) =>
      _maintenanceApi.createMaintenanceHistory(history);
  static Future<EquipmentMaintenanceHistory> updateMaintenanceHistory(
          String historyId, EquipmentMaintenanceHistory history) =>
      _maintenanceApi.updateMaintenanceHistory(historyId, history);
  static Future<void> archiveMaintenanceHistory(String historyId, String reason) =>
      _maintenanceApi.archiveMaintenanceHistory(historyId, reason);

  static Future<void> unarchiveMaintenanceHistory(String historyId) =>
      _maintenanceApi.unarchiveMaintenanceHistory(historyId);

  static Future<EquipmentMaintenanceHistory> getMaintenanceHistoryById(String id) =>
      _maintenanceApi.getMaintenanceHistoryById(id);

  static Future<String> uploadMaintenancePhoto({
    required String maintenanceId,
    required List<int> photoBytes,
    required String fileName,
    String? comment,
    required String timing,
  }) => _maintenanceApi.uploadMaintenancePhoto(
        maintenanceId: maintenanceId,
        photoBytes: photoBytes,
        fileName: fileName,
        comment: comment,
        timing: timing,
      );

  static Future<AvailableExecutorsResponse> getAvailableExecutors() =>
      _maintenanceApi.getAvailableExecutors();

  // --- Repair Time Standard Methods ---
  static Future<List<RepairTimeStandard>> getRepairTimeStandards({bool includeArchived = false}) =>
      _maintenanceApi.getRepairTimeStandards(includeArchived: includeArchived);
  static Future<RepairTimeStandard> createRepairTimeStandard(RepairTimeStandard standard) =>
      _maintenanceApi.createRepairTimeStandard(standard);
  static Future<RepairTimeStandard> updateRepairTimeStandard(String standardId, RepairTimeStandard standard) =>
      _maintenanceApi.updateRepairTimeStandard(standardId, standard);
  static Future<void> archiveRepairTimeStandard(String standardId, String reason) =>
      _maintenanceApi.archiveRepairTimeStandard(standardId, reason);
  static Future<void> unarchiveRepairTimeStandard(String standardId) =>
      _maintenanceApi.unarchiveRepairTimeStandard(standardId);



  // --- Group Methods ---
  static Future<List<TrainingGroup>> getAllTrainingGroups({
    String? searchQuery,
    String? groupTypeId,
    bool? isActive,
    bool? isArchived,
    String? trainerId,
    String? instructorId,
    String? managerId,
  }) =>
      _groupsApi.getAllTrainingGroups(
        searchQuery: searchQuery,
        groupTypeId: groupTypeId,
        isActive: isActive,
        isArchived: isArchived,
        trainerId: trainerId,
        instructorId: instructorId,
        managerId: managerId,
      );
  static Future<TrainingGroup> getTrainingGroupById(String id) => _groupsApi.getTrainingGroupById(id);
  static Future<TrainingGroup> createTrainingGroup(TrainingGroup group) => _groupsApi.createTrainingGroup(group);
  static Future<TrainingGroup> updateTrainingGroup(TrainingGroup group) => _groupsApi.updateTrainingGroup(group);
  static Future<void> deleteTrainingGroup(String id) => _groupsApi.deleteTrainingGroup(id);

  static Future<List<AnalyticGroup>> getAllAnalyticGroups({bool? isActive, bool? isArchived}) =>
      _groupsApi.getAllAnalyticGroups(isActive: isActive, isArchived: isArchived);
  static Future<AnalyticGroup> getAnalyticGroupById(String id) => _groupsApi.getAnalyticGroupById(id);
  static Future<AnalyticGroup> createAnalyticGroup(AnalyticGroup group) => _groupsApi.createAnalyticGroup(group);
  static Future<AnalyticGroup> updateAnalyticGroup(AnalyticGroup group) => _groupsApi.updateAnalyticGroup(group);
  static Future<void> deleteAnalyticGroup(String id) => _groupsApi.deleteAnalyticGroup(id);

  static Future<List<GroupSchedule>> getGroupSchedules(String groupId) => _groupsApi.getGroupSchedules(groupId);
  static Future<GroupSchedule> createGroupSchedule(String groupId, GroupSchedule slot) =>
      _groupsApi.createGroupSchedule(groupId, slot);
  static Future<GroupSchedule> updateGroupSchedule(GroupSchedule slot) => _groupsApi.updateGroupSchedule(slot);
  static Future<void> deleteGroupSchedule(String id) => _groupsApi.deleteGroupSchedule(id);

  static Future<List<String>> getTrainingGroupMembers(String groupId) => _groupsApi.getTrainingGroupMembers(groupId);
  static Future<void> addTrainingGroupMember(String groupId, String userId) =>
      _groupsApi.addTrainingGroupMember(groupId, userId);
  static Future<void> removeTrainingGroupMember(String groupId, String userId) =>
      _groupsApi.removeTrainingGroupMember(groupId, userId);

  static Future<List<TrainingGroupType>> getAllTrainingGroupTypes() => _groupsApi.getAllTrainingGroupTypes();


  // --- Chat Methods ---
  static Future<List<Chat>> getChats() => _chatApi.getChats();
  static Future<List<Message>> getMessages(String chatId, {int limit = 50, int offset = 0}) =>
      _chatApi.getMessages(chatId, limit: limit, offset: offset);
  static Future<String> createOrGetPrivateChat(String peerId) => _chatApi.createOrGetPrivateChat(peerId);
  static Future<Chat> createGroupChat(String name, List<String> memberIds) =>
      _chatApi.createGroupChat(name, memberIds);
  static Future<Message> uploadChatAttachment(
          {required String chatId, required List<int> fileBytes, required String fileName}) =>
      _chatApi.uploadChatAttachment(chatId: chatId, fileBytes: fileBytes, fileName: fileName);


  // --- Manager Methods ---
  static Future<List<User>> getAssignedClients(String managerId) => _managerApi.getAssignedClients(managerId);
  static Future<List<User>> getAssignedInstructors(String managerId) =>
      _managerApi.getAssignedInstructors(managerId);
  static Future<List<User>> getAssignedTrainers(String managerId) => _managerApi.getAssignedTrainers(managerId);

  static Future<List<String>> getAssignedClientIds(String managerId) => _managerApi.getAssignedClientIds(managerId);
  static Future<List<String>> getAssignedInstructorIds(String managerId) =>
      _managerApi.getAssignedInstructorIds(managerId);
  static Future<List<String>> getAssignedTrainerIds(String managerId) => _managerApi.getAssignedTrainerIds(managerId);

  static Future<void> assignClientsToManager(String managerId, List<String> clientIds) =>
      _managerApi.assignClientsToManager(managerId, clientIds);
  static Future<void> assignInstructorsToManager(String managerId, List<String> instructorIds) =>
      _managerApi.assignInstructorsToManager(managerId, instructorIds);
  static Future<void> assignTrainersToManager(String managerId, List<String> trainerIds) =>
      _managerApi.assignTrainersToManager(managerId, trainerIds);


  // --- Instructor Methods ---
  static Future<List<User>> getAssignedClientsForInstructor(String instructorId) =>
      _instructorApi.getAssignedClientsForInstructor(instructorId);
  static Future<List<User>> getAssignedTrainersForInstructor(String instructorId) =>
      _instructorApi.getAssignedTrainersForInstructor(instructorId);
  static Future<User> getAssignedManagerForInstructor(String instructorId) =>
      _instructorApi.getAssignedManagerForInstructor(instructorId);


  // --- Client Methods ---
  static Future<Map<String, dynamic>> getClientDashboardData(String userId) =>
      _clientApi.getClientDashboardData(userId);
  static Future<User?> getTrainerForClient() => _clientApi.getTrainerForClient();
  static Future<User?> getInstructorForClient() => _clientApi.getInstructorForClient();
  static Future<User?> getManagerForClient() => _clientApi.getManagerForClient();

  static Future<List<AnthropometryMeasurement>> getAnthropometryMeasurements(
          {bool? includeArchived}) =>
      _clientApi.getAnthropometryMeasurements(includeArchived: includeArchived);
  static Future<AnthropometryMeasurement> saveAnthropometryMeasurement(
          AnthropometryMeasurement measurement) =>
      _clientApi.saveAnthropometryMeasurement(measurement);
  static Future<AnthropometryFixed?> getFixedAnthropometry() =>
      _clientApi.getFixedAnthropometry();
  static Future<AnthropometryFixed> saveFixedAnthropometry(
          AnthropometryFixed fixedData) =>
      _clientApi.saveFixedAnthropometry(fixedData);

  static Future<Map<String, dynamic>> getSomatotypeProfile() => _clientApi.getSomatotypeProfile();
  static Future<WhtrProfiles> getWhtrProfiles() => _clientApi.getWhtrProfiles();

  static Future<WhtrProfile> getWhtrForMeasurement(String measurementId, {String? clientId}) async {
    if (clientId != null) {
      return _adminApi.getWhtrForMeasurement(clientId, measurementId);
    }
    return _clientApi.getWhtrForMeasurement(measurementId);
  }

  static Future<Map<String, dynamic>> uploadAnthropometryPhoto(
          {required List<int> photoBytes, required String fileName}) =>
      _clientApi.uploadAnthropometryPhoto(photoBytes: photoBytes, fileName: fileName);

  static Future<User> updateClientProfile(Map<String, dynamic> profileData) =>
      _clientApi.updateClientProfile(profileData);
  static Future<List<dynamic>> getCalorieTrackingData() => _clientApi.getCalorieTrackingData();
  static Future<Map<String, dynamic>> getClientPreferences() =>
      _clientApi.getClientPreferences();
  static Future<void> saveClientPreferences(Map<String, dynamic> preferences) =>
      _clientApi.saveClientPreferences(preferences);
  static Future<Map<String, dynamic>> getProgressData() =>
      _clientApi.getProgressData();

  static Future<List<VisualizationDataPoint>> getVisualizationData(
          List<String> measurementIds) =>
      _clientApi.getVisualizationData(measurementIds);


  // --- Catalog and Schedule Methods ---
  static Future<List<dynamic>> getTrainingPlans() => _catalogsApi.getTrainingPlans();
  static Future<List<GoalTraining>> getTrainingGoals() => _catalogsApi.getTrainingGoals();
  static Future<List<LevelTraining>> getTrainingLevels() => _catalogsApi.getTrainingLevels();
  static Future<List<ScheduleItem>> getSchedule() => _scheduleApi.getSchedule();
  static Future<List<dynamic>> getWorkSchedules() => _scheduleApi.getWorkSchedules();
  static Future<void> updateWorkSchedule(Map<String, dynamic> schedule) =>
      _scheduleApi.updateWorkSchedule(schedule);

  static Future<Map<String, dynamic>> getRecommendation(String clientId, {String? measurementId}) =>
      _recommendationApi.getRecommendation(clientId, measurementId: measurementId);

  static Future<MetabolicProfile> getMetabolicRate(String clientId, String measurementId) =>
      _recommendationApi.getMetabolicRate(clientId, measurementId);


  // --- Admin Methods ---
  static Future<List<AnthropometryMeasurement>> getAnthropometryMeasurementsForClient(
          String clientId, {bool? includeArchived}) =>
      _adminApi.getAnthropometryMeasurementsForClient(clientId, includeArchived: includeArchived);

  static Future<AnthropometryMeasurement> saveAnthropometryMeasurementForClient(
    String clientId,
    AnthropometryMeasurement measurement,
  ) =>
      _adminApi.saveAnthropometryMeasurementForClient(clientId, measurement);

  static Future<AnthropometryFixed?> getFixedAnthropometryForClient(
          String clientId) =>
      _adminApi.getFixedAnthropometryForClient(clientId);
  
  static Future<AnthropometryFixed> saveFixedAnthropometryForClient(
    String clientId,
    AnthropometryFixed fixedData,
  ) =>
      _adminApi.saveFixedAnthropometryForClient(clientId, fixedData);

  static Future<Map<String, dynamic>> getSomatotypeProfileForClient(String clientId) =>
      _adminApi.getSomatotypeProfileForClient(clientId);
  static Future<WhtrProfiles> getWhtrProfilesForClient(String clientId) =>
      _adminApi.getWhtrProfilesForClient(clientId);

  static Future<void> archiveAnthropometryMeasurement(
          String clientId, String measurementId, String reason) =>
      _adminApi.archiveAnthropometryMeasurement(clientId, measurementId, reason);

  static Future<void> unarchiveAnthropometryMeasurement(
          String clientId, String measurementId) =>
      _adminApi.unarchiveAnthropometryMeasurement(clientId, measurementId);

  // --- Support Staff Methods ---
  static Future<List<SupportStaff>> getAllSupportStaff({bool? isArchived}) =>
      _supportStaffApi.getAll(includeArchived: isArchived);

  static Future<SupportStaff> getSupportStaffById(String id) =>
      _supportStaffApi.getById(id);

  static Future<SupportStaff> createSupportStaff(SupportStaff staff) =>
      _supportStaffApi.create(staff);

  static Future<SupportStaff> updateSupportStaff(String id, SupportStaff staff) =>
      _supportStaffApi.update(id, staff);

  static Future<void> archiveSupportStaff(String id, String reason) =>
      _supportStaffApi.archive(id, reason);

  static Future<void> unarchiveSupportStaff(String id) =>
      _supportStaffApi.unarchive(id);

  static Future<List<Competency>> getCompetencies(String staffId) =>
      _supportStaffApi.getCompetencies(staffId);

  static Future<Competency> addCompetency(String staffId, Competency competency) =>
      _supportStaffApi.addCompetency(staffId, competency);

  static Future<void> deleteCompetency(String staffId, String competencyId) =>
      _supportStaffApi.deleteCompetency(staffId, competencyId);
}
