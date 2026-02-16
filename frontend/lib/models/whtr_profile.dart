class WhtrProfile {
  final double ratio;
  final String gradation;

  WhtrProfile({required this.ratio, required this.gradation});

  factory WhtrProfile.fromJson(Map<String, dynamic> json) {
    return WhtrProfile(
      ratio: (json['ratio'] as num).toDouble(),
      gradation: json['gradation'] as String,
    );
  }
}
