import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/goal_training.dart';
import '../models/level_training.dart';
import '../services/api_service.dart';

final goalsTrainingProvider = FutureProvider<List<GoalTraining>>((ref) async {
  return ApiService.getTrainingGoals();
});

final levelsTrainingProvider = FutureProvider<List<LevelTraining>>((ref) async {
  return ApiService.getTrainingLevels();
});
