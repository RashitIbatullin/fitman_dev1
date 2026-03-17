import 'package:freezed_annotation/freezed_annotation.dart';

part 'employee_profile.freezed.dart';
part 'employee_profile.g.dart';

@freezed
class EmployeeProfile with _$EmployeeProfile {
  const factory EmployeeProfile({
    required int userId,
    String? specialization,
    int? workExperience,
    @Default(false) bool canMaintainEquipment,
  }) = _EmployeeProfile;

  factory EmployeeProfile.fromJson(Map<String, dynamic> json) =>
      _$EmployeeProfileFromJson(json);
}
