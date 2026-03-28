import 'package:json_annotation/json_annotation.dart';

part 'trainer_profile.g.dart';

@JsonSerializable()
class TrainerProfile {
  final String userId;

  TrainerProfile({
    required this.userId,
  });

  factory TrainerProfile.fromMap(Map<String, dynamic> map) =>
      _$TrainerProfileFromJson(map);

  Map<String, dynamic> toMap() => _$TrainerProfileToJson(this);
}
