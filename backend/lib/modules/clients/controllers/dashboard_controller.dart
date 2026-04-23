import 'dart:convert';
import 'package:fitman_common/fitman_common.dart';
import 'package:shelf/shelf.dart';
import '../../../config/database.dart';

class DashboardController {
  static const _headers = {'Content-Type': 'application/json'};

  static Future<Response> getClientDashboardData(
      Request request, String userId) async {
    try {
      final authenticatedUser = request.context['user'] as Map<String, dynamic>?;
      if (authenticatedUser == null || authenticatedUser['userId'] == null) {
        return Response.forbidden(jsonEncode({'error': 'Not authenticated.'}));
      }
      final authenticatedUserId = authenticatedUser['userId'] as String;
      final authenticatedUserRoles = (authenticatedUser['roles'] as List).cast<String>();

      // Authorization: Allow if the user is requesting their own data, or if they are an admin/manager.
      final canAccess = (authenticatedUserId == userId) ||
          authenticatedUserRoles.contains('admin') ||
          authenticatedUserRoles.contains('manager');

      if (!canAccess) {
        return Response.forbidden(jsonEncode({
          'error': 'You do not have permission to view this dashboard.'
        }));
      }

      final clientRepository = Database().clients;

      // Fetch last 7 measurements for the chart, for the user specified in the URL.
      final recentMeasurements =
          await clientRepository.getAnthropometryMeasurements(
        userId,
        limit: 7,
      );

      // TODO: Implement other data fetching from database
      final dashboardData = DashboardData(
        nextTraining: NextTraining(
          title: 'Силовая тренировка',
          time: DateTime.now().add(const Duration(days: 1)),
        ),
        trainingProgress: const TrainingProgress(
          completed: 5,
          total: 8,
          caloriesBurned: 1500,
          attendance: 85,
        ),
        goalProgress: const GoalProgress(
          goal: 'Похудение',
          currentWeight: 75,
          targetWeight: 70,
          avgDeficit: -350,
        ),
        achievements: const [
          Achievement(icon: 'star', color: 'amber'),
          Achievement(icon: 'local_fire_department', color: 'red'),
          Achievement(icon: 'fitness_center', color: 'blue'),
        ],
        recentMeasurements: recentMeasurements, // Add the real data here
      );

      return Response.ok(jsonEncode(dashboardData.toJson()), headers: _headers);
    } catch (e, s) {
      print('Error in getClientDashboardData: $e');
      print(s);
      return Response.internalServerError(
        body: jsonEncode({'error': 'Internal Server Error: $e'}),
        headers: _headers,
      );
    }
  }
}
