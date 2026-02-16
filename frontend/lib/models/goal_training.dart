class GoalTraining {
  final int id;
  final String name;

  GoalTraining({required this.id, required this.name});

  factory GoalTraining.fromJson(Map<String, dynamic> json) {
    return GoalTraining(
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
