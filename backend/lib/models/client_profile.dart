class ClientProfile {
  final int userId;
  final int? goalTrainingId;
  final int? levelTrainingId;
  final bool? trackCalories;
  final double? coeffActivity;

  ClientProfile({
    required this.userId,
    this.goalTrainingId,
    this.levelTrainingId,
    this.trackCalories,
    this.coeffActivity,
  });

  factory ClientProfile.fromMap(Map<String, dynamic> map) {
    return ClientProfile(
      userId: map['user_id'] as int,
      goalTrainingId: map['goal_training_id'] as int?,
      levelTrainingId: map['level_training_id'] as int?,
      trackCalories: map['track_calories'] as bool?,
      coeffActivity: (map['coeff_activity'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'goal_training_id': goalTrainingId,
      'level_training_id': levelTrainingId,
      'track_calories': trackCalories,
      'coeff_activity': coeffActivity,
    };
  }
}
