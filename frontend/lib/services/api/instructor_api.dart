import 'package:fitman_common/fitman_common.dart';
import 'base_api.dart';

/// Service class for instructor-specific APIs.
class InstructorApiService extends BaseApiService {
  InstructorApiService({super.client});

  /// Fetches the list of clients assigned to a specific instructor.
  Future<List<User>> getAssignedClientsForInstructor(String instructorId) async {
    final data = await get('/api/instructors/$instructorId/clients');
    return (data as List).map((json) => User.fromJson(json)).toList();
  }

  /// Fetches the list of trainers assigned to a specific instructor.
  Future<List<User>> getAssignedTrainersForInstructor(String instructorId) async {
    final data = await get('/api/instructors/$instructorId/trainers');
    return (data as List).map((json) => User.fromJson(json)).toList();
  }

  /// Fetches the manager assigned to a specific instructor.
  Future<User> getAssignedManagerForInstructor(String instructorId) async {
    final data = await get('/api/instructors/$instructorId/manager');
    return User.fromJson(data);
  }
}