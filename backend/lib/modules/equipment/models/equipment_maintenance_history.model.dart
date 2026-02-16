import 'dart:convert';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'equipment_maintenance_history.model.freezed.dart';
part 'equipment_maintenance_history.model.g.dart';

@freezed
@JsonSerializable() // Add JsonSerializable here
class MaintenancePhoto with _$MaintenancePhoto {
  const factory MaintenancePhoto({
    required String url,
    required String note,
  }) = _MaintenancePhoto;

  factory MaintenancePhoto.fromJson(Map<String, dynamic> json) =>
      _$MaintenancePhotoFromJson(json); // Re-add this line
}

@freezed
@JsonSerializable(explicitToJson: true)
class EquipmentMaintenanceHistory with _$EquipmentMaintenanceHistory {
  const factory EquipmentMaintenanceHistory({
    required String id,
    required String equipmentItemId,
    required DateTime dateSent,
    DateTime? dateReturned,
    required String descriptionOfWork,
    double? cost,
    String? performedBy,
    List<MaintenancePhoto>? photos,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    DateTime? archivedAt,
    String? archivedBy,
    String? archivedReason,
    String? note,
  }) = _EquipmentMaintenanceHistory;

  factory EquipmentMaintenanceHistory.fromJson(Map<String, dynamic> json) => // Re-add this line
      _$EquipmentMaintenanceHistoryFromJson(json);

  factory EquipmentMaintenanceHistory.fromMap(Map<String, dynamic> map) {
    // The 'photos' field from postgres might be a JSON string
    final photosJson = map['photos'];
    List<dynamic>? photosList;
    if (photosJson is String) {
      photosList = jsonDecode(photosJson);
    } else if (photosJson is List) {
      photosList = photosJson;
    }

    return EquipmentMaintenanceHistory.fromJson({
      'id': map['id'].toString(),
      'equipmentItemId': map['equipment_item_id'].toString(),
      'dateSent': map['date_sent'],
      'dateReturned': map['date_returned'],
      'descriptionOfWork': map['description_of_work'],
      'cost': map['cost'],
      'performedBy': map['performed_by'],
      'photos': photosList, // Pass the decoded list
      'createdAt': map['created_at'],
      'updatedAt': map['updated_at'],
      'createdBy': map['created_by']?.toString(),
      'updatedBy': map['updated_by']?.toString(),
      'archivedAt': map['archived_at'],
      'archivedBy': map['archived_by']?.toString(),
      'archivedReason': map['archived_reason'],
      'note': map['note'],
    });
  }
}