import 'dart:convert';
import 'package:fitman_backend/security/access_policy.dart';
import 'package:fitman_common/fitman_common.dart';
import 'package:shelf/shelf.dart';
import '../../../config/database.dart';
import '../../../errors/app_exception.dart';

class DashboardController {
  static const _headers = {'Content-Type': 'application/json'};

  static Future<Response> getClientDashboardData(
      Request request, String userId) async {
    try {
      final authenticatedUser = request.context['user'] as User?;
      if (authenticatedUser == null) {
        return Response.forbidden(jsonEncode({'error': 'Not authenticated.'}));
      }
      final authenticatedUserId = authenticatedUser.id;

      // Свои данные или сотрудник с правом просмотра клиентов.
      final canAccess = authenticatedUserId == userId ||
          AccessPolicy.isManagerOrAdmin(authenticatedUser);

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
    } catch (error, stackTrace) {
      throw InternalException(cause: error, stackTrace: stackTrace);
    }
  }
}
