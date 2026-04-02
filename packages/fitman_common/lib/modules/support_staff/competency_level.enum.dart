import 'package:freezed_annotation/freezed_annotation.dart';

enum CompetencyLevel {
  @JsonValue('trainee')
  trainee,
  @JsonValue('junior')
  junior,
  @JsonValue('middle')
  middle,
  @JsonValue('senior')
  senior,
  @JsonValue('expert')
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
