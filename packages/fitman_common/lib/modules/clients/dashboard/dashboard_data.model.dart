import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_data.model.freezed.dart';
part 'dashboard_data.model.g.dart';

@freezed
class DashboardData with _$DashboardData {
  const factory DashboardData({
    NextTraining? nextTraining,
    TrainingProgress? trainingProgress,
    GoalProgress? goalProgress,
    required List<Achievement> achievements,
  }) = _DashboardData;

  factory DashboardData.fromJson(Map<String, dynamic> json) =>
      _$DashboardDataFromJson(json);
}

@freezed
class NextTraining with _$NextTraining {
  const factory NextTraining({
    required String title,
    required DateTime time,
  }) = _NextTraining;

  factory NextTraining.fromJson(Map<String, dynamic> json) =>
      _$NextTrainingFromJson(json);
}

@freezed
class TrainingProgress with _$TrainingProgress {
  const factory TrainingProgress({
    required int completed,
    required int total,
    required int caloriesBurned,
    required int attendance,
  }) = _TrainingProgress;

  factory TrainingProgress.fromJson(Map<String, dynamic> json) =>
      _$TrainingProgressFromJson(json);
}

@freezed
class GoalProgress with _$GoalProgress {
  const factory GoalProgress({
    required String goal,
    required double currentWeight,
    required double targetWeight,
    required int avgDeficit,
  }) = _GoalProgress;

  factory GoalProgress.fromJson(Map<String, dynamic> json) =>
      _$GoalProgressFromJson(json);
}

@freezed
class Achievement with _$Achievement {
  const factory Achievement({
    required String icon,
    required String color,
  }) = _Achievement;

  factory Achievement.fromJson(Map<String, dynamic> json) =>
      _$AchievementFromJson(json);
}
