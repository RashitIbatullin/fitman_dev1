import 'package:freezed_annotation/freezed_annotation.dart';

part 'equipment_maintenance_history.model.freezed.dart';
part 'equipment_maintenance_history.model.g.dart';

@freezed
class MaintenancePhoto with _$MaintenancePhoto {
  const factory MaintenancePhoto({
    required String url,
    required String note,
  }) = _MaintenancePhoto;

  factory MaintenancePhoto.fromJson(Map<String, dynamic> json) =>
      _$MaintenancePhotoFromJson(json);
}

@freezed
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

  factory EquipmentMaintenanceHistory.fromJson(Map<String, dynamic> json) =>
      _$EquipmentMaintenanceHistoryFromJson(json);
}
