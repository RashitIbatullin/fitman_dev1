import 'package:freezed_annotation/freezed_annotation.dart';

part 'instructor_profile.freezed.dart';
part 'instructor_profile.g.dart';

@freezed
class InstructorProfile with _$InstructorProfile {
  const factory InstructorProfile({
    required String userId,
    @Default(false) bool isDuty,
    @Default(false) bool canReplaceTrainer,
    @Default(false) bool canCreatePlan,
  }) = _InstructorProfile;

  factory InstructorProfile.fromJson(Map<String, dynamic> json) =>
      _$InstructorProfileFromJson(json);
}
