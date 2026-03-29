import 'package:json_annotation/json_annotation.dart';

part 'employee_profile.g.dart';

@JsonSerializable()
class EmployeeProfile {
  final String userId;
  final String? specialization;
  final int? workExperience;
  final bool canMaintainEquipment;

  EmployeeProfile({
    required this.userId,
    this.specialization,
    this.workExperience,
    this.canMaintainEquipment = false,
  });

  factory EmployeeProfile.fromMap(Map<String, dynamic> map) =>
      _$EmployeeProfileFromJson(map);

  Map<String, dynamic> toMap() => _$EmployeeProfileToJson(this);
}
