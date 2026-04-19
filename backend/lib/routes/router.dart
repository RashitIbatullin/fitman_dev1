import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf.dart';
import '../controllers/auth_controller.dart';
import '../modules/users/controllers/users_controller.dart';
import '../controllers/training_controller.dart';
import '../controllers/schedule_controller.dart';
import '../middleware/auth_middleware.dart';
import '../modules/clients/controllers/dashboard_controller.dart';
import '../modules/clients/controllers/anthropometry_controller.dart';
import '../modules/clients/controllers/calorie_tracking_controller.dart';
import '../modules/clients/controllers/progress_controller.dart';
import '../controllers/catalogs/work_schedule_controller.dart';
import '../modules/clients/controllers/client_preference_controller.dart';
import '../controllers/catalogs_controller.dart';
import '../controllers/recommendations_controller.dart';
import '../modules/chat/controllers/chat_http_controller.dart';
import '../modules/chat/controllers/chat_ws_controller.dart';
import '../modules/groups/controllers/training_group_controller.dart';
import '../modules/groups/controllers/analytic_group_controller.dart';
import '../modules/groups/controllers/group_schedule_controller.dart';
import '../modules/groups/controllers/training_group_types_controller.dart';
import '../modules/rooms/controllers/room.controller.dart';
import '../modules/equipment/controllers/equipment_item.controller.dart';
import '../modules/equipment/controllers/equipment_type.controller.dart';
import '../modules/equipment/controllers/maintenance_controller.dart';
import '../modules/rooms/controllers/building_controller.dart';
import '../config/database.dart';
import '../modules/equipment/services/equipment.service.dart';
import '../modules/equipment/repositories/equipment_type.repository.dart';
import '../modules/equipment/repositories/equipment_item.repository.dart';
import '../modules/equipment/repositories/maintenance_repository.dart';
import '../modules/equipment/services/maintenance_service.dart';
import '../modules/roles/controllers/manager_controller.dart';
import '../modules/roles/controllers/instructor_controller.dart';
import '../modules/support_staff/controllers/support_staff.controller.dart';
import '../modules/support_staff/services/support_staff.service.dart';
import '../modules/support_staff/repositories/support_staff.repository.dart';
import '../modules/competencies/repositories/competency_repository.dart';
import '../modules/employees/services/employee_competency_service.dart';
import '../modules/equipment/controllers/repair_time_standard_controller.dart';
import '../modules/equipment/repositories/repair_time_standard_repository.dart';
import '../modules/equipment/services/repair_time_standard_service.dart';
import '../modules/employees/controllers/employee_competency_controller.dart';

final Database _db = Database();

// Repositories
final _equipmentTypeRepository = EquipmentTypeRepositoryImpl(_db);
final _equipmentItemRepository = EquipmentItemRepositoryImpl(_db);
final _maintenanceRepository = MaintenanceRepositoryImpl(_db);
final _repairTimeStandardRepository = RepairTimeStandardRepositoryImpl(_db);
final _competencyRepository = CompetencyRepositoryImpl(_db);
final _supportStaffRepository = SupportStaffRepositoryImpl(_db, _competencyRepository);

// Services
final _equipmentService = EquipmentServiceImpl(_equipmentTypeRepository, _equipmentItemRepository);
final _maintenanceService = MaintenanceService(_maintenanceRepository);
final _repairTimeStandardService = RepairTimeStandardService(_repairTimeStandardRepository);
final _supportStaffService = SupportStaffService(_supportStaffRepository, _competencyRepository);
final _employeeCompetencyService = EmployeeCompetencyService(_competencyRepository);

// Controllers
final _supportStaffController = SupportStaffController(_supportStaffService);
final _employeeCompetencyController = EmployeeCompetencyController(_employeeCompetencyService);
final _trainingGroupsController = TrainingGroupsController(_db);
final _analyticGroupsController = AnalyticGroupsController(_db);
final _groupScheduleController = GroupScheduleController(_db);
final _trainingGroupTypesController = TrainingGroupTypesController(_db);
final _roomController = RoomController(_db);
final _equipmentItemController = EquipmentItemController(_db);
final _equipmentTypeController = EquipmentTypeController(_db, _equipmentService);
final _maintenanceController = MaintenanceController(_maintenanceService);
final _repairTimeStandardController = RepairTimeStandardController(_repairTimeStandardService);
final _buildingController = BuildingController(_db);

Handler _protectedHandler(Handler handler) {
  return requireAuth()(handler);
}

Middleware _requireTrainerOrAdmin() {
  return (Handler innerHandler) {
    return (Request request) {
      final user = request.context['user'] as Map<String, dynamic>?;
      final role = user?['role'] as String?;
      if (user == null || (role != 'trainer' && role != 'admin')) {
        return Response.forbidden('{"error": "Trainer or Admin access required"}');
      }
      return innerHandler(request);
    };
  };
}

Middleware _requireManagerOrAdmin() {
  return (Handler innerHandler) {
    return (Request request) {
      final user = request.context['user'] as Map<String, dynamic>?;
      final role = user?['role'] as String?;
      if (user == null || (role != 'manager' && role != 'admin')) {
        return Response.forbidden('{"error": "Manager or Admin access required"}');
      }
      return innerHandler(request);
    };
  };
}

Handler _adminHandler(Handler handler) {
  return requireAuth()(requireRole('admin')(handler));
}

Handler _trainerHandler(Handler handler) {
  return requireAuth()(_requireTrainerOrAdmin()(handler));
}

Handler _managerHandler(Handler handler) {
  return requireAuth()(_requireManagerOrAdmin()(handler));
}

Middleware _requireInstructorOrAdmin() {
  return (Handler innerHandler) {
    return (Request request) {
      final user = request.context['user'] as Map<String, dynamic>?;
      final role = user?['role'] as String?;
      if (user == null || (role != 'instructor' && role != 'admin')) {
        return Response.forbidden('{"error": "Instructor or Admin access required"}');
      }
      return innerHandler(request);
    };
  };
}

Handler _instructorHandler(Handler handler) {
  return requireAuth()(_requireInstructorOrAdmin()(handler));
}

final Router router = Router()
// Public routes
  ..get('/api/health', (_) => Response.ok('{"status": "OK", "message": "FitMan Dart API MVP1"}'))
  ..post('/api/auth/login', AuthController.login)
  ..post('/api/auth/register', AuthController.register)

// Protected routes - общие
  ..get('/api/auth/check', (Request request) => _protectedHandler(AuthController.checkAuth)(request))
  ..get('/api/profile', (Request request) => _protectedHandler(UsersController.getProfile)(request))
  ..get('/api/catalogs/goals-training', (Request request) => _protectedHandler(CatalogsController.getGoalsTraining)(request))
  ..get('/api/catalogs/levels-training', (Request request) => _protectedHandler(CatalogsController.getLevelsTraining)(request))
  ..mount('/api/training_group_types', (Request request) => _protectedHandler(_trainingGroupTypesController.router.call)(request))

// User management routes (только для админа)
  ..get('/api/users', (Request request) => _adminHandler(UsersController.getUsers)(request))
  ..post('/api/users', (Request request) => _adminHandler(UsersController.createUser)(request))
  ..get('/api/users/<id>', (Request request, String id) => _protectedHandler((Request req) => UsersController.getUserById(req, id))(request))
  ..put('/api/users/<id>', (Request request, String id) => _protectedHandler((Request req) => UsersController.updateUser(req, id))(request))
  ..delete('/api/users/<id>', (Request request, String id) => _adminHandler((Request req) => UsersController.deleteUser(req, id))(request))
  ..get('/api/users/<id>/roles', (Request request, String id) => _adminHandler((Request req) => UsersController.getUserRoles(req, id))(request))
  ..put('/api/users/<id>/roles', (Request request, String id) => requireAuth()(requireRole('admin')((Request req) => UsersController.updateUserRoles(req, id)))(request))
  ..post('/api/users/<id>/avatar', (Request request, String id) => _protectedHandler((Request req) => UsersController.uploadAvatar(req, id))(request))
  ..post('/api/users/reset-password', (Request request) => _adminHandler(UsersController.resetPassword)(request))
  ..get('/api/roles', (Request request) => _adminHandler(UsersController.getRoles)(request))

// Employee Competency routes (только для админа)
  ..get('/api/employees/<userId>/competencies', (Request request, String userId) {
    return _adminHandler((Request req) => _employeeCompetencyController.getCompetencies(req, userId))(request);
  })
  ..post('/api/employees/<userId>/competencies', (Request request, String userId) {
    return _adminHandler((Request req) => _employeeCompetencyController.addCompetency(req, userId))(request);
  })
  ..delete('/api/employees/<userId>/competencies/<compId>', (Request request, String userId, String compId) {
    return _adminHandler((Request req) => _employeeCompetencyController.deleteCompetency(req, userId, compId))(request);
  })

// Training routes
  ..get('/api/training/plans', (Request request) => _protectedHandler(TrainingController.getTrainingPlans)(request))
  ..get('/api/training/exercises', (Request request) => _protectedHandler(TrainingController.getExercises)(request))

// Schedule routes
  ..get('/api/schedule', (Request request) => _protectedHandler(ScheduleController.getSchedule)(request))
  ..post('/api/schedule', (Request request) => _trainerHandler(ScheduleController.createSchedule)(request))

// Manager routes
  ..get('/api/manager/clients', (Request request) => _managerHandler(ManagerController.getAssignedClients)(request))
  ..get('/api/manager/instructors', (Request request) => _managerHandler(ManagerController.getAssignedInstructors)(request))
  ..get('/api/manager/trainers', (Request request) => _managerHandler(ManagerController.getAssignedTrainers)(request))
  ..post('/api/managers/<id>/clients', (Request request, String id) => _adminHandler((Request req) => ManagerController.assignClients(req, id))(request))
  ..get('/api/managers/<id>/clients/ids', (Request request, String id) => _adminHandler((Request req) => ManagerController.getAssignedClientIds(req, id))(request))
  ..post('/api/managers/<id>/instructors', (Request request, String id) => _adminHandler((Request req) => ManagerController.assignInstructors(req, id))(request))
  ..get('/api/managers/<id>/instructors/ids', (Request request, String id) => _adminHandler((Request req) => ManagerController.getAssignedInstructorIds(req, id))(request))
  ..post('/api/managers/<id>/trainers', (Request request, String id) => _adminHandler((Request req) => ManagerController.assignTrainers(req, id))(request))
  ..get('/api/managers/<id>/trainers/ids', (Request request, String id) => _adminHandler((Request req) => ManagerController.getAssignedTrainerIds(req, id))(request))

  // Routes for admins to get data for a specific manager
  ..get('/api/managers/<id>/clients', (Request request, String id) => _adminHandler((Request req) => ManagerController.getAssignedClientsForManager(req, id))(request))
  ..get('/api/managers/<id>/instructors', (Request request, String id) => _adminHandler((Request req) => ManagerController.getAssignedInstructorsForManager(req, id))(request))
  ..get('/api/managers/<id>/trainers', (Request request, String id) => _adminHandler((Request req) => ManagerController.getAssignedTrainersForManager(req, id))(request))

// Instructor routes
  ..get('/api/instructor/clients', (Request request) => _instructorHandler(InstructorController.getAssignedClients)(request))
  ..get('/api/instructor/trainers', (Request request) => _instructorHandler(InstructorController.getAssignedTrainers)(request))
  ..get('/api/instructor/manager', (Request request) => _instructorHandler(InstructorController.getAssignedManager)(request))

  // Routes for admins to get data for a specific instructor
  ..get('/api/instructors/<id>/clients', (Request request, String id) => _adminHandler((Request req) => InstructorController.getAssignedClientsForInstructor(req, id))(request))
  ..get('/api/instructors/<id>/trainers', (Request request, String id) => _adminHandler((Request req) => InstructorController.getAssignedTrainersForInstructor(req, id))(request))
  ..get('/api/instructors/<id>/manager', (Request request, String id) => _adminHandler((Request req) => InstructorController.getAssignedManagerForInstructor(req, id))(request))

// Dashboard routes
  ..get('/api/dashboard/client', (Request request) => _protectedHandler(DashboardController.getClientDashboardData)(request))

// Client routes
  ..put('/api/client/profile', (Request request) => _protectedHandler(UsersController.updateClientProfile)(request))
  ..get('/api/client/trainer', (Request request) => _protectedHandler(UsersController.getTrainerForClient)(request))
  ..get('/api/client/instructor', (Request request) => _protectedHandler(UsersController.getInstructorForClient)(request))
  ..get('/api/client/manager', (Request request) => _protectedHandler(UsersController.getManagerForClient)(request))
  ..get('/api/client/anthropometry', (Request request) => _protectedHandler(AnthropometryController.getAnthropometry)(request))
  ..post('/api/client/anthropometry', (Request request) => _protectedHandler(AnthropometryController.saveAnthropometry)(request))
  ..get('/api/client/anthropometry/fixed', (Request request) => _protectedHandler(AnthropometryController.getFixedAnthropometry)(request))
  ..post('/api/client/anthropometry/fixed', (Request request) => _protectedHandler(AnthropometryController.saveFixedAnthropometry)(request))
  ..post('/api/client/anthropometry/photo', (Request request) => _protectedHandler(AnthropometryController.uploadPhoto)(request))
  ..get('/api/client/anthropometry/somatotype', (Request request) => _protectedHandler(AnthropometryController.getSomatotype)(request))
  ..get('/api/client/anthropometry/whtr-profiles', (Request request) => _protectedHandler(AnthropometryController.getWhtrProfiles)(request))
  ..get('/api/client/anthropometry/measurements/<id>/whtr', (Request request, String id) => _protectedHandler((Request req) => AnthropometryController.getWhtrForMeasurement(req, id))(request))
  ..get('/api/client/calorie-tracking', (Request request) => _protectedHandler(CalorieTrackingController.getCalorieTrackingDataForClient)(request))
  ..get('/api/client/progress', (Request request) => _protectedHandler(ProgressController.getProgressDataForClient)(request))
  ..get('/api/recommendations/<id>', (Request request, String id) => _protectedHandler((Request req) => RecommendationsController.getRecommendation(req, id))(request))
  ..get('/api/client/preferences', (Request request) => _protectedHandler(ClientPreferenceController.getClientPreferences)(request))
  ..post('/api/client/preferences', (Request request) => _protectedHandler(ClientPreferenceController.saveClientPreferences)(request))

// Admin routes for client anthropometry
  ..get('/api/admin/clients/<id>/anthropometry', (Request request, String id) => _adminHandler((Request req) => AnthropometryController.getAnthropometry(req, id))(request))
  ..post('/api/admin/clients/<id>/anthropometry', (Request request, String id) => _adminHandler((Request req) => AnthropometryController.saveAnthropometry(req, id))(request))
  ..get('/api/admin/clients/<id>/anthropometry/fixed', (Request request, String id) => _adminHandler((Request req) => AnthropometryController.getFixedAnthropometry(req, id))(request))
  ..post('/api/admin/clients/<id>/anthropometry/fixed', (Request request, String id) => _adminHandler((Request req) => AnthropometryController.saveFixedAnthropometry(req, id))(request))
  ..get('/api/admin/clients/<id>/anthropometry/somatotype', (Request request, String id) => _adminHandler((Request req) => AnthropometryController.getSomatotype(req, id))(request))
  ..get('/api/admin/clients/<id>/anthropometry/whtr-profiles', (Request request, String id) => _adminHandler((Request req) => AnthropometryController.getWhtrProfiles(req, id))(request))
  ..post('/api/admin/clients/<id>/anthropometry/<measurementId>/archive', (Request request, String id, String measurementId) => _adminHandler((Request req) => AnthropometryController.archiveAnthropometryMeasurement(req, id, measurementId))(request))
  ..put('/api/admin/clients/<id>/anthropometry/<measurementId>/unarchive', (Request request, String id, String measurementId) => _adminHandler((Request req) => AnthropometryController.unarchiveAnthropometryMeasurement(req, id, measurementId))(request))
  ..get('/api/admin/clients/<id>/measurements/<measurementId>/whtr', (Request request, String id, String measurementId) => _adminHandler((Request req) => AnthropometryController.getWhtrForMeasurement(req, measurementId))(request))


// Work Schedule routes
  ..get('/api/work-schedules', (Request request) => _protectedHandler(WorkScheduleController.getWorkSchedules)(request))
  ..post('/api/work-schedules', (Request request) => _adminHandler(WorkScheduleController.createWorkSchedule)(request))
  ..put('/api/work-schedules', (Request request) => _adminHandler(WorkScheduleController.updateWorkSchedule)(request))
  ..delete('/api/work-schedules', (Request request) => _adminHandler(WorkScheduleController.deleteWorkSchedule)(request))

// Chat routes
  ..get('/api/chats', (Request request) => _protectedHandler(ChatHttpController.getChats)(request))
  ..get('/api/chats/<id>/messages', (Request request, String id) => _protectedHandler((Request req) => ChatHttpController.getMessages(req, id))(request))
  ..post('/api/chats/private', (Request request) => _protectedHandler(ChatHttpController.createOrGetPrivateChat)(request))
  ..post('/api/chat', (Request request) => _protectedHandler((Request req) => ChatHttpController.createGroupChat(req))(request)) // New route for group chat
  ..get('/api/chat/ws', (Request request) => _protectedHandler(ChatWsController.handler)(request))

// Training Groups routes (Admin access)
  ..mount('/api/training_groups', _adminHandler(_trainingGroupsController.router.call))
// Analytic Groups routes (Admin access)
  ..mount('/api/analytic_groups', _adminHandler(_analyticGroupsController.router.call))
// Group Schedule routes (Admin access)
  ..mount('/api/group_schedules', _adminHandler(_groupScheduleController.router.call))

// Infrastructure routes
  ..mount('/api/rooms', _adminHandler(_roomController.router.call))
  ..mount('/api/equipment/items', _adminHandler(_equipmentItemController.handler))
  ..mount('/api/equipment/types', _adminHandler(_equipmentTypeController.handler))
  ..mount('/api/maintenance', _adminHandler(_maintenanceController.handler))
  ..mount('/api/maintenance/standards', _adminHandler(_repairTimeStandardController.router.call))
  ..mount('/api/buildings', _adminHandler(_buildingController.router.call))

// Support Staff routes (Admin access)
  ..get('/api/support-staff', _adminHandler(_supportStaffController.getAll))
  ..post('/api/support-staff', _adminHandler(_supportStaffController.create))
  ..get('/api/support-staff/<id>', (Request request, String id) {
    return _adminHandler((Request req) => _supportStaffController.getById(req, id))(request);
  })
  ..put('/api/support-staff/<id>', (Request request, String id) {
    return _adminHandler((Request req) => _supportStaffController.update(req, id))(request);
  })
  ..delete('/api/support-staff/<id>', (Request request, String id) {
    return _adminHandler((Request req) => _supportStaffController.archive(req, id))(request);
  })
  ..put('/api/support-staff/<id>/unarchive', (Request request, String id) {
    return _adminHandler((Request req) => _supportStaffController.unarchive(req, id))(request);
  })
  ..get('/api/support-staff/<staffId>/competencies', (Request request, String staffId) {
    return _adminHandler((Request req) => _supportStaffController.getCompetencies(req, staffId))(request);
  })
  ..post('/api/support-staff/<staffId>/competencies', (Request request, String staffId) {
    return _adminHandler((Request req) => _supportStaffController.addCompetency(req, staffId))(request);
  })
  ..delete('/api/support-staff/<staffId>/competencies/<compId>', (Request request, String staffId, String compId) {
    return _adminHandler((Request req) => _supportStaffController.deleteCompetency(req, staffId, compId))(request);
  });
