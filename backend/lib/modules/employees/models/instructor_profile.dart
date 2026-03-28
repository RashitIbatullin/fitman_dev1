import 'package:json_annotation/json_annotation.dart';

part 'instructor_profile.g.dart';

@JsonSerializable()
class InstructorProfile {
  final String userId;
  final bool isDuty;
  final bool canReplaceTrainer;
  final bool canCreatePlan;

  InstructorProfile({
    required this.userId,
    this.isDuty = false,
    this.canReplaceTrainer = false,
    this.canCreatePlan = false,
  });

  factory InstructorProfile.fromMap(Map<String, dynamic> map) =>
      _$InstructorProfileFromJson(map);

  Map<String, dynamic> toMap() => _$InstructorProfileToJson(this);
}
