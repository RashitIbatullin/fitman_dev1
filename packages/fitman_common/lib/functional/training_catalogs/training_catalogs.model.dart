import 'package:freezed_annotation/freezed_annotation.dart';

part 'training_catalogs.model.freezed.dart';
part 'training_catalogs.model.g.dart';

@freezed
class GoalTraining with _$GoalTraining {
  const factory GoalTraining({
    required String id,
    required String name,
  }) = _GoalTraining;

  factory GoalTraining.fromJson(Map<String, dynamic> json) =>
      _$GoalTrainingFromJson(json);
}

@freezed
class LevelTraining with _$LevelTraining {
  const factory LevelTraining({
    required String id,
    required String name,
  }) = _LevelTraining;

  factory LevelTraining.fromJson(Map<String, dynamic> json) =>
      _$LevelTrainingFromJson(json);
}
