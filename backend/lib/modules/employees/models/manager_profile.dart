import 'package:json_annotation/json_annotation.dart';

part 'manager_profile.g.dart';

@JsonSerializable()
class ManagerProfile {
  final String userId;
  final bool isDuty;

  ManagerProfile({
    required this.userId,
    this.isDuty = false,
  });

  factory ManagerProfile.fromMap(Map<String, dynamic> map) =>
      _$ManagerProfileFromJson(map);

  Map<String, dynamic> toMap() => _$ManagerProfileToJson(this);
}
