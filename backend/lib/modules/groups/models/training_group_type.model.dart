import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'training_group_type.model.g.dart';

@JsonSerializable()
class TrainingGroupType extends Equatable {
  final int id;
  final String name;
  final String title;
  @JsonKey(name: 'min_participants')
  final int minParticipants;
  @JsonKey(name: 'max_participants')
  final int maxParticipants;
  final String? description;
  final String? icon;
  final String? color;

  const TrainingGroupType({
    required this.id,
    required this.name,
    required this.title,
    required this.minParticipants,
    required this.maxParticipants,
    this.description,
    this.icon,
    this.color,
  });

  factory TrainingGroupType.fromJson(Map<String, dynamic> json) =>
      _$TrainingGroupTypeFromJson(json);

  Map<String, dynamic> toJson() => _$TrainingGroupTypeToJson(this);

  @override
  List<Object?> get props => [
        id,
        name,
        title,
        minParticipants,
        maxParticipants,
        description,
        icon,
        color,
      ];
}
