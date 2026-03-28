import 'package:freezed_annotation/freezed_annotation.dart';

part 'trainer_profile.freezed.dart';
part 'trainer_profile.g.dart';

@freezed
class TrainerProfile with _$TrainerProfile {
  const factory TrainerProfile({
    required String userId,
  }) = _TrainerProfile;

  factory TrainerProfile.fromJson(Map<String, dynamic> json) =>
      _$TrainerProfileFromJson(json);
}
