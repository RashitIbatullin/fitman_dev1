import 'package:freezed_annotation/freezed_annotation.dart';

part 'analytical_profiles.freezed.dart';
part 'analytical_profiles.g.dart';

@freezed
class WhtrProfile with _$WhtrProfile {
  const factory WhtrProfile({
    required double ratio,
    required String gradation,
  }) = _WhtrProfile;

  factory WhtrProfile.fromJson(Map<String, dynamic> json) =>
      _$WhtrProfileFromJson(json);
}

@freezed
class MetabolicProfile with _$MetabolicProfile {
  const factory MetabolicProfile({
    required double bmr,
    required double tdee,
  }) = _MetabolicProfile;

  factory MetabolicProfile.fromJson(Map<String, dynamic> json) =>
      _$MetabolicProfileFromJson(json);
}
