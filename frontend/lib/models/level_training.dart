class LevelTraining {
  final int id;
  final String name;

  LevelTraining({required this.id, required this.name});

  factory LevelTraining.fromJson(Map<String, dynamic> json) {
    return LevelTraining(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
