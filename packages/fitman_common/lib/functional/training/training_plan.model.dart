import 'package:freezed_annotation/freezed_annotation.dart';

part 'training_plan.model.freezed.dart';
part 'training_plan.model.g.dart';

@freezed
class TrainingPlan with _$TrainingPlan {
  const factory TrainingPlan({
    required String id,
    required String name,
    required String goal,
    required String level,
    required String description,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _TrainingPlan;

  factory TrainingPlan.fromJson(Map<String, dynamic> json) =>
      _$TrainingPlanFromJson(json);
}
