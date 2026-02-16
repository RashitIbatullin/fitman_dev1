class ClientProfile {
  final int? goalTrainingId;
  final int? levelTrainingId;
  final bool trackCalories;
  final double coeffActivity;

  ClientProfile({
    this.goalTrainingId,
    this.levelTrainingId,
    required this.trackCalories,
    required this.coeffActivity,
  });

  factory ClientProfile.fromJson(Map<String, dynamic> json) {
    // Helper to safely parse int from dynamic
    int? parseInt(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    return ClientProfile(
      goalTrainingId: parseInt(json['goal_training_id']),
      levelTrainingId: parseInt(json['level_training_id']),
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
