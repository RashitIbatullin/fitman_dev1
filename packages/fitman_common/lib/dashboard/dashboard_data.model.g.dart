// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_data.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DashboardDataImpl _$$DashboardDataImplFromJson(Map<String, dynamic> json) =>
    _$DashboardDataImpl(
      nextTraining:
          NextTraining.fromJson(json['next_training'] as Map<String, dynamic>),
      trainingProgress: TrainingProgress.fromJson(
          json['training_progress'] as Map<String, dynamic>),
      goalProgress:
          GoalProgress.fromJson(json['goal_progress'] as Map<String, dynamic>),
      achievements: (json['achievements'] as List<dynamic>)
          .map((e) => Achievement.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$DashboardDataImplToJson(_$DashboardDataImpl instance) =>
    <String, dynamic>{
      'next_training': instance.nextTraining,
      'training_progress': instance.trainingProgress,
      'goal_progress': instance.goalProgress,
      'achievements': instance.achievements,
    };

_$NextTrainingImpl _$$NextTrainingImplFromJson(Map<String, dynamic> json) =>
    _$NextTrainingImpl(
      title: json['title'] as String,
      time: DateTime.parse(json['time'] as String),
    );

Map<String, dynamic> _$$NextTrainingImplToJson(_$NextTrainingImpl instance) =>
    <String, dynamic>{
      'title': instance.title,
      'time': instance.time.toIso8601String(),
    };

_$TrainingProgressImpl _$$TrainingProgressImplFromJson(
        Map<String, dynamic> json) =>
    _$TrainingProgressImpl(
      completed: (json['completed'] as num).toInt(),
      total: (json['total'] as num).toInt(),
      caloriesBurned: (json['calories_burned'] as num).toInt(),
      attendance: (json['attendance'] as num).toInt(),
    );

Map<String, dynamic> _$$TrainingProgressImplToJson(
        _$TrainingProgressImpl instance) =>
    <String, dynamic>{
      'completed': instance.completed,
      'total': instance.total,
      'calories_burned': instance.caloriesBurned,
      'attendance': instance.attendance,
    };

_$GoalProgressImpl _$$GoalProgressImplFromJson(Map<String, dynamic> json) =>
    _$GoalProgressImpl(
      goal: json['goal'] as String,
      currentWeight: (json['current_weight'] as num).toDouble(),
      targetWeight: (json['target_weight'] as num).toDouble(),
      avgDeficit: (json['avg_deficit'] as num).toInt(),
    );

Map<String, dynamic> _$$GoalProgressImplToJson(_$GoalProgressImpl instance) =>
    <String, dynamic>{
      'goal': instance.goal,
      'current_weight': instance.currentWeight,
      'target_weight': instance.targetWeight,
      'avg_deficit': instance.avgDeficit,
    };

_$AchievementImpl _$$AchievementImplFromJson(Map<String, dynamic> json) =>
    _$AchievementImpl(
      icon: json['icon'] as String,
      color: json['color'] as String,
    );

Map<String, dynamic> _$$AchievementImplToJson(_$AchievementImpl instance) =>
    <String, dynamic>{
      'icon': instance.icon,
      'color': instance.color,
    };
