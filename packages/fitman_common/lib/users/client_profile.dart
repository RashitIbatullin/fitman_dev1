class ClientProfile {
  final String? goalTrainingId;
  final String? levelTrainingId;
  final bool trackCalories;
  final double coeffActivity;

  ClientProfile({
    this.goalTrainingId,
    this.levelTrainingId,
    required this.trackCalories,
    required this.coeffActivity,
  });

  factory ClientProfile.fromMap(Map<String, dynamic> map) =>
      ClientProfile.fromJson(map);

  factory ClientProfile.fromJson(Map<String, dynamic> json) {
    return ClientProfile(
      goalTrainingId: json['goal_training_id']?.toString(),
      levelTrainingId: json['level_training_id']?.toString(),
      trackCalories: json['track_calories'] ?? true,
      coeffActivity: (json['coeff_activity'] as num?)?.toDouble() ?? 1.2,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'goal_training_id': goalTrainingId,
      'level_training_id': levelTrainingId,
      'track_calories': trackCalories,
      'coeff_activity': coeffActivity,
    };
  }
}
