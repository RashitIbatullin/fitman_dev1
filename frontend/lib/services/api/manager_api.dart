import '../../modules/users/models/user.dart';
import 'base_api.dart';

/// Service class for manager-specific APIs.
class ManagerApiService extends BaseApiService {
  ManagerApiService({super.client});

  // --- Get Assigned Users ---

  Future<List<User>> getAssignedClients(String managerId) async {
    final data = await get('/api/managers/$managerId/clients');
    return (data as List).map((json) => User.fromJson(json)).toList();
  }

  Future<List<User>> getAssignedInstructors(String managerId) async {
    final data = await get('/api/managers/$managerId/instructors');
    return (data as List).map((json) => User.fromJson(json)).toList();
  }

  Future<List<User>> getAssignedTrainers(String managerId) async {
    final data = await get('/api/managers/$managerId/trainers');
    return (data as List).map((json) => User.fromJson(json)).toList();
  }

  // --- Get Assigned User IDs ---

  Future<List<String>> getAssignedClientIds(String managerId) async {
    final data = await get('/api/managers/$managerId/clients/ids');
    return (data as List).cast<String>().toList();
  }

  Future<List<String>> getAssignedInstructorIds(String managerId) async {
    final data = await get('/api/managers/$managerId/instructors/ids');
    return (data as List).cast<String>().toList();
  }

  Future<List<String>> getAssignedTrainerIds(String managerId) async {
    final data = await get('/api/managers/$managerId/trainers/ids');
    return (data as List).cast<String>().toList();
  }

  // --- Assign Users ---

  Future<void> assignClientsToManager(String managerId, List<String> clientIds) async {
    await post('/api/managers/$managerId/clients', body: {'client_ids': clientIds});
  }

  Future<void> assignInstructorsToManager(String managerId, List<String> instructorIds) async {
    await post('/api/managers/$managerId/instructors', body: {'instructor_ids': instructorIds});
  }

  Future<void> assignTrainersToManager(String managerId, List<String> trainerIds) async {
    await post('/api/managers/$managerId/trainers', body: {'trainer_ids': trainerIds});
  }
}