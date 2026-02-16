import '../../models/goal_training.dart';
import '../../models/level_training.dart';
import 'base_api.dart';

/// Service class for catalog-related APIs.
class CatalogsApiService extends BaseApiService {
  CatalogsApiService({super.client});

  /// Fetches all training plan templates.
  Future<List<dynamic>> getTrainingPlans() async {
    final data = await get('/api/training/plans');
    return data['plans'] as List;
  }

  /// Fetches all training goals.
  Future<List<GoalTraining>> getTrainingGoals() async {
    final data = await get('/api/catalogs/goals-training');
    return (data as List).map((json) => GoalTraining.fromJson(json)).toList();
  }

  /// Fetches all training levels.
  Future<List<LevelTraining>> getTrainingLevels() async {
    final data = await get('/api/catalogs/levels-training');
    return (data as List).map((json) => LevelTraining.fromJson(json)).toList();
  }
}