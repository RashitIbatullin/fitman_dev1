import 'package:freezed_annotation/freezed_annotation.dart';

part 'building.model.freezed.dart';
part 'building.model.g.dart';

class NullableDateTimeConverter implements JsonConverter<DateTime?, String?> {
  const NullableDateTimeConverter();

  @override
  DateTime? fromJson(String? json) => json == null ? null : DateTime.parse(json);

  @override
  String? toJson(DateTime? object) => object?.toIso8601String();
}

@freezed
class Building with _$Building {
  const factory Building({
    required String id,
    required String name,
    required String address,
    String? note,
    @NullableDateTimeConverter() DateTime? createdAt,
    @NullableDateTimeConverter() DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    @NullableDateTimeConverter() DateTime? archivedAt,
    String? archivedBy,
    String? archivedByName,
    String? archivedReason,
  }) = _Building;

  factory Building.fromJson(Map<String, dynamic> json) => _$BuildingFromJson(json);
}
