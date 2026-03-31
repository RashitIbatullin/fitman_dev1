import 'package:freezed_annotation/freezed_annotation.dart';

part 'manager_profile.freezed.dart';
part 'manager_profile.g.dart';

@freezed
class ManagerProfile with _$ManagerProfile {
  const factory ManagerProfile({
    required String userId,
    @Default(false) bool isDuty,
  }) = _ManagerProfile;

  factory ManagerProfile.fromJson(Map<String, dynamic> json) =>
      _$ManagerProfileFromJson(json);

  factory ManagerProfile.fromMap(Map<String, dynamic> map) =>
      ManagerProfile.fromJson(map);
}
