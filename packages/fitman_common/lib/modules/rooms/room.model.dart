// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fitman_common/custom/time_of_day_custom.dart';
import 'room_type.enum.dart';

part 'room.model.freezed.dart';
part 'room.model.g.dart';

// Custom converter for RoomType enum to/from int
class RoomTypeConverter implements JsonConverter<RoomType, int> {
  const RoomTypeConverter();

  @override
  RoomType fromJson(int json) {
    return RoomType.values.firstWhere((e) => e.value == json);
  }

  @override
  int toJson(RoomType object) {
    return object.value;
  }
}

@freezed
class Room with _$Room {
  const factory Room({
    required String id,
    required String name,
    String? description,
    String? roomNumber,
    @RoomTypeConverter() required RoomType type,
    int? floor,
    String? buildingId,
    String? buildingName,
    @Default(30) int maxCapacity,
    double? area,
    TimeOfDayCustom? openTime,
    TimeOfDayCustom? closeTime,
    @Default([]) List<int> workingDays,
    @Default(true) bool isActive,
    String? deactivateReason,
    DateTime? deactivateAt,
    String? deactivateBy,
    @Default([]) List<String> photoUrls,
    String? floorPlanUrl,
    String? note,
    DateTime? archivedAt,
    String? archivedReason,
    String? updatedBy,
    String? archivedBy,
    String? archivedByName,
  }) = _Room;

  factory Room.fromJson(Map<String, dynamic> json) => _$RoomFromJson(json);
  factory Room.fromMap(Map<String, dynamic> map) => Room.fromJson(map);
}
