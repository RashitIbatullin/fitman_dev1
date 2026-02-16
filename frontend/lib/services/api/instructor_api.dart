import '../../modules/users/models/user.dart';
import 'base_api.dart';

/// Service class for instructor-specific APIs.
class InstructorApiService extends BaseApiService {
  InstructorApiService({super.client});

  /// Fetches the list of clients assigned to a specific instructor.
  Future<List<User>> getAssignedClientsForInstructor(int instructorId) async {
    final data = await get('/api/instructors/$instructorId/clients');
    return (data as List).map((json) => User.fromJson(json)).toList();
  }

  /// Fetches the list of trainers assigned to a specific instructor.
  Future<List<User>> getAssignedTrainersForInstructor(int instructorId) async {
    final data = await get('/api/instructors/$instructorId/trainers');
    return (data as List).map((json) => User.fromJson(json)).toList();
  }

  /// Fetches the manager assigned to a specific instructor.
  Future<User> getAssignedManagerForInstructor(int instructorId) async {
    final data = await get('/api/instructors/$instructorId/manager');
    return User.fromJson(data);
  }
}