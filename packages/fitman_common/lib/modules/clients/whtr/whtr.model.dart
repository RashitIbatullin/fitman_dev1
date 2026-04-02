import 'package:freezed_annotation/freezed_annotation.dart';

part 'whtr.model.freezed.dart';
part 'whtr.model.g.dart';

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
class WhtrProfiles with _$WhtrProfiles {
  const factory WhtrProfiles({
    required WhtrProfile start,
    required WhtrProfile finish,
  }) = _WhtrProfiles;

  factory WhtrProfiles.fromJson(Map<String, dynamic> json) =>
      _$WhtrProfilesFromJson(json);
}
