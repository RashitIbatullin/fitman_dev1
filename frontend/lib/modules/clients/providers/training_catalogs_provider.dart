import 'package:fitman_app/services/api_service.dart';
import 'package:fitman_common/fitman_common.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'training_catalogs_provider.g.dart';

@riverpod
Future<List<GoalTraining>> trainingGoals(Ref ref) async {
  return ApiService.getTrainingGoals();
}

@riverpod
Future<List<LevelTraining>> trainingLevels(Ref ref) async {
  return ApiService.getTrainingLevels();
}
