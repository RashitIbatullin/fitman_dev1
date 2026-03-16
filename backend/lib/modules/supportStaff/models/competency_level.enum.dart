enum CompetencyLevel {
  trainee,
  junior,
  middle,
  senior,
  expert,
}

extension CompetencyLevelExtension on CompetencyLevel {
  String get localizedName {
    switch (this) {
      case CompetencyLevel.trainee:
        return 'Стажёр';
      case CompetencyLevel.junior:
        return 'Младший специалист';
      case CompetencyLevel.middle:
        return 'Специалист';
      case CompetencyLevel.senior:
        return 'Ведущий специалист';
      case CompetencyLevel.expert:
        return 'Эксперт';

    }
  }
}
