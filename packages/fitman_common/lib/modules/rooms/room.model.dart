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
    @JsonKey(name: 'room_number') String? roomNumber,
    @RoomTypeConverter() required RoomType type,
    @JsonKey(name: 'floor') int? floor,
    @JsonKey(name: 'building_id') String? buildingId,
    @JsonKey(name: 'building_name') String? buildingName,
    @JsonKey(name: 'max_capacity') @Default(30) int maxCapacity,
    double? area,
    @JsonKey(name: 'open_time') TimeOfDayCustom? openTime,
    @JsonKey(name: 'close_time') TimeOfDayCustom? closeTime,
    @JsonKey(name: 'working_days') @Default([]) List<int> workingDays,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'deactivate_reason') String? deactivateReason,
    @JsonKey(name: 'deactivate_at') DateTime? deactivateAt,
    @JsonKey(name: 'deactivate_by') String? deactivateBy,
    @JsonKey(name: 'photo_urls') @Default([]) List<String> photoUrls,
    @JsonKey(name: 'floor_plan_url') String? floorPlanUrl,
    String? note,
    @JsonKey(name: 'archived_at') DateTime? archivedAt,
    @JsonKey(name: 'archived_reason') String? archivedReason,
    @JsonKey(name: 'archived_by') String? archivedBy,
    @JsonKey(name: 'archived_by_name') String? archivedByName,
  }) = _Room;

  factory Room.fromJson(Map<String, dynamic> json) => _$RoomFromJson(json);
  factory Room.fromMap(Map<String, dynamic> map) => Room.fromJson(map);
}
