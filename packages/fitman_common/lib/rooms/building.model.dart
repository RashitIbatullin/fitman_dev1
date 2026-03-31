import 'package:freezed_annotation/freezed_annotation.dart';
import 'nullable_date_time_converter.dart';

part 'building.model.freezed.dart';
part 'building.model.g.dart';

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
  factory Building.fromMap(Map<String, dynamic> map) => Building.fromJson(map);
}
