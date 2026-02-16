import 'dart:convert';
import 'package:postgres/postgres.dart'; // Import for Time type
import 'package:fitman_backend/modules/rooms/models/room/room_type.enum.dart';

class Room {
  const Room({
    this.id,
    required this.name,
    this.description,
    this.roomNumber,
    required this.type,
    this.floor,
    this.buildingId,
    this.buildingName,
    required this.maxCapacity,
    this.area,
    this.openTime,
    this.closeTime,
    this.workingDays,
    this.isActive = true,
    this.deactivateReason,
    this.deactivateAt,
    this.deactivateBy,
    this.photoUrls,
    this.floorPlanUrl,
    this.note,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
    this.archivedAt,
    this.archivedBy,
    this.archivedReason,
    this.archivedByName,
  });

  final String? id;
  final String name;
  final String? description;
  final String? roomNumber;
  final RoomType type;
  final int? floor; // Changed to int?
  final String? buildingId;
  final String? buildingName;
  final int maxCapacity;
  final double? area;
  final Time? openTime;
  final Time? closeTime;
  final List<int>? workingDays;
  final bool isActive;
  final String? deactivateReason;
  final DateTime? deactivateAt;
  final String? deactivateBy;
  final List<String>? photoUrls;
  final String? floorPlanUrl;
  final String? note;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? createdBy;
  final String? updatedBy;
  final DateTime? archivedAt;
  final String? archivedBy;
  final String? archivedReason;
  final String? archivedByName;

  factory Room.fromMap(Map<String, dynamic> map) {
    // Handle area conversion
    final areaValue = map['area'];
    final double? parsedArea = areaValue == null
        ? null
        : (areaValue is String ? double.tryParse(areaValue) : (areaValue as num).toDouble());

    // Handle Time conversion
    final Time? parsedOpenTime = map['open_time'] is DateTime
        ? Time(
            (map['open_time'] as DateTime).hour,
            (map['open_time'] as DateTime).minute,
            (map['open_time'] as DateTime).second,
          )
        : null; // Assuming null if not DateTime from DB
    final Time? parsedCloseTime = map['close_time'] is DateTime
        ? Time(
            (map['close_time'] as DateTime).hour,
            (map['close_time'] as DateTime).minute,
            (map['close_time'] as DateTime).second,
          )
        : null; // Assuming null if not DateTime from DB

    // Handle workingDays (JSONB)
    dynamic decodedWorkingDays;
    if (map['working_days'] is String) {
      decodedWorkingDays = jsonDecode(map['working_days'] as String);
    } else {
      decodedWorkingDays = map['working_days'];
    }
    final List<int>? parsedWorkingDays =
        (decodedWorkingDays is List) ? decodedWorkingDays.cast<int>() : null;

    // Handle photoUrls (JSONB)
    dynamic decodedPhotoUrls;
    if (map['photo_urls'] is String) {
      decodedPhotoUrls = jsonDecode(map['photo_urls'] as String);
    } else {
      decodedPhotoUrls = map['photo_urls'];
    }
    final List<String>? parsedPhotoUrls =
        (decodedPhotoUrls is List) ? decodedPhotoUrls.cast<String>() : null;

    return Room(
      id: map['id']?.toString(),
      name: map['name'] as String,
      description: map['description'] as String?,
      roomNumber: map['room_number'] as String?,
      type: RoomType.values.firstWhere((e) => e.value == map['type'] as int),
      floor: map['floor'] as int?, // Changed from String?
      buildingId: map['building_id']?.toString(),
      buildingName: map['building_name'] as String?,
      maxCapacity: map['max_capacity'] as int,
      area: parsedArea,
      openTime: parsedOpenTime,
      closeTime: parsedCloseTime,
      workingDays: parsedWorkingDays,
      isActive: map['is_active'] as bool,
      deactivateReason: map['deactivate_reason'] as String?,
      deactivateAt: map['deactivate_at'] is DateTime
          ? map['deactivate_at'] as DateTime
          : (map['deactivate_at'] == null
              ? null
              : DateTime.parse(map['deactivate_at'] as String)),
      deactivateBy: map['deactivate_by']?.toString(),
      photoUrls: parsedPhotoUrls,
      floorPlanUrl: map['floor_plan_url'] as String?,
      note: map['note'] as String?,
      createdAt: map['created_at'] is DateTime
          ? map['created_at'] as DateTime
          : (map['created_at'] == null
              ? null
              : DateTime.parse(map['created_at'] as String)),
      updatedAt: map['updated_at'] is DateTime
          ? map['updated_at'] as DateTime
          : (map['updated_at'] == null
              ? null
              : DateTime.parse(map['updated_at'] as String)),
      createdBy: map['created_by']?.toString(),
      updatedBy: map['updated_by']?.toString(),
      archivedAt: map['archived_at'] is DateTime
          ? map['archived_at'] as DateTime
          : (map['archived_at'] == null
              ? null
              : DateTime.parse(map['archived_at'] as String)),
      archivedBy: map['archived_by']?.toString(),
      archivedReason: map['archived_reason'] as String?,
      archivedByName: map['archived_by_name'] as String?,
    );
  }

  factory Room.fromJson(Map<String, dynamic> json) {
    // This is for JSON coming from frontend or external API, which typically doesn't use snake_case for fields
    // and might not have all DB-generated fields.
    final double? parsedArea = json['area'] == null
        ? null
        : (json['area'] is String
            ? double.tryParse(json['area'])
            : (json['area'] as num).toDouble());

    // Manual parsing of TimeOfDay strings if coming from JSON
    Time? parseTimeFromString(String? timeString) {
      if (timeString == null) return null;
      final parts = timeString.split(':');
      if (parts.length >= 2) {
        return Time(int.parse(parts[0]), int.parse(parts[1]));
      }
      return null;
    }

    // Safely parse type and maxCapacity to prevent crash on null
    final typeValue = json['type'] as int? ?? 0;
    final maxCapacityValue = json['max_capacity'] as int? ?? 0;

    return Room(
      id: json['id'] as String?,
      name: json['name'] as String,
      description: json['description'] as String?,
      roomNumber: json['room_number'] as String?,
      type: RoomType.values.firstWhere((e) => e.value == typeValue, orElse: () => RoomType.groupHall),
      floor: json['floor'] as int?, // Changed from String?
      buildingId: json['building_id'] as String?,
      buildingName: json['buildingName'] as String?,
      maxCapacity: maxCapacityValue,
      area: parsedArea,
      openTime: parseTimeFromString(json['open_time'] as String?),
      closeTime: parseTimeFromString(json['close_time'] as String?),
      workingDays:
          (json['working_days'] as List<dynamic>?)?.cast<int>() ?? const [],
      isActive: json['is_active'] as bool? ?? true,
      deactivateReason: json['deactivate_reason'] as String?,
      deactivateAt: json['deactivate_at'] == null
          ? null
          : DateTime.parse(json['deactivate_at'] as String),
      deactivateBy: json['deactivate_by'] as String?,
      photoUrls:
          (json['photo_urls'] as List<dynamic>?)?.cast<String>() ?? const [],
      floorPlanUrl: json['floor_plan_url'] as String?,
      note: json['note'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      createdBy: json['created_by'] as String?,
      updatedBy: json['updated_by'] as String?,
      archivedAt: json['archived_at'] == null
          ? null
          : DateTime.parse(json['archived_at'] as String),
      archivedBy: json['archived_by'] as String?,
      archivedReason: json['archived_reason'] as String?,
      archivedByName: json['archived_by_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'room_number': roomNumber,
      'type': type.value, // Convert enum to int value
      'floor': floor, // Changed from String?
      'building_id': buildingId, // Use snake_case for DB
      'building_name': buildingName,
      'max_capacity': maxCapacity, // Use snake_case for DB
      'area': area,
      'open_time': openTime?.toString(), // Convert Time to string
      'close_time': closeTime?.toString(), // Convert Time to string
      'working_days': workingDays,
      'is_active': isActive,
      'deactivate_reason': deactivateReason,
      'deactivate_at': deactivateAt?.toIso8601String(),
      'deactivate_by': deactivateBy,
      'photo_urls': photoUrls, // Use snake_case for DB
      'floor_plan_url': floorPlanUrl, // Use snake_case for DB
      'note': note,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'created_by': createdBy,
      'updated_by': updatedBy,
      'archived_at': archivedAt?.toIso8601String(),
      'archived_by': archivedBy,
      'archived_reason': archivedReason,
      'archived_by_name': archivedByName,
    };
  }
}