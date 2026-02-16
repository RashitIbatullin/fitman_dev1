import '../../modules/users/models/user.dart';
import 'base_api.dart';

/// Service class for manager-specific APIs.
class ManagerApiService extends BaseApiService {
  ManagerApiService({super.client});

  // --- Get Assigned Users ---

  Future<List<User>> getAssignedClients(int managerId) async {
    final data = await get('/api/managers/$managerId/clients');
    return (data as List).map((json) => User.fromJson(json)).toList();
  }

  Future<List<User>> getAssignedInstructors(int managerId) async {
    final data = await get('/api/managers/$managerId/instructors');
    return (data as List).map((json) => User.fromJson(json)).toList();
  }

  Future<List<User>> getAssignedTrainers(int managerId) async {
    final data = await get('/api/managers/$managerId/trainers');
    return (data as List).map((json) => User.fromJson(json)).toList();
  }

  // --- Get Assigned User IDs ---

  Future<List<int>> getAssignedClientIds(int managerId) async {
    final data = await get('/api/managers/$managerId/clients/ids');
    return (data as List).cast<int>().toList();
  }

  Future<List<int>> getAssignedInstructorIds(int managerId) async {
    final data = await get('/api/managers/$managerId/instructors/ids');
    return (data as List).cast<int>().toList();
  }

  Future<List<int>> getAssignedTrainerIds(int managerId) async {
    final data = await get('/api/managers/$managerId/trainers/ids');
    return (data as List).cast<int>().toList();
  }

  // --- Assign Users ---

  Future<void> assignClientsToManager(int managerId, List<int> clientIds) async {
    await post('/api/managers/$managerId/clients', body: {'client_ids': clientIds});
  }

  Future<void> assignInstructorsToManager(int managerId, List<int> instructorIds) async {
    await post('/api/managers/$managerId/instructors', body: {'instructor_ids': instructorIds});
  }

  Future<void> assignTrainersToManager(int managerId, List<int> trainerIds) async {
    await post('/api/managers/$managerId/trainers', body: {'trainer_ids': trainerIds});
  }
}