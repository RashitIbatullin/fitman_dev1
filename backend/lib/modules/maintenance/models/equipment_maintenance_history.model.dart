import 'package:freezed_annotation/freezed_annotation.dart';

part 'equipment_maintenance_history.model.freezed.dart';
part 'equipment_maintenance_history.model.g.dart';

/// Тип ТО
enum MaintenanceType {
  /// Плановое профилактическое
  preventive,
  /// Ремонт по факту неисправности
  corrective
}

/// Статус ТО
enum MaintenanceStatus {
  /// Проблема зафиксирована
  reported,
  /// В работе
  inProgress,
  /// Завершено
  completed,
  /// Отменено
  cancelled
}

/// Фотография ТО
enum PhotoTiming {
  before,
  after
}

@freezed
class MaintenancePhoto with _$MaintenancePhoto {
  const factory MaintenancePhoto({
    required String id,
    required String maintenanceId,
    required String url,
    String? comment,
    required PhotoTiming timing,
    DateTime? takenAt,
    String? takenBy,
  }) = _MaintenancePhoto;

  factory MaintenancePhoto.fromJson(Map<String, dynamic> json) =>
      _$MaintenancePhotoFromJson(json);
}

@freezed
class EquipmentMaintenanceHistory with _$EquipmentMaintenanceHistory {
  const factory EquipmentMaintenanceHistory({
    required String id,
    required String equipmentItemId,
    String? equipmentName,
    required MaintenanceType type,
    required MaintenanceStatus status,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? equipmentAvailableFrom,
    required String reportedProblem,
    String? workDescription,
    required String reportedBy,
    String? assignedToUserId,
    String? assignedToStaffId,
    String? relatedBookingId,
    @Default(false) bool causedDowntime,
    DateTime? updatedAt,
    DateTime? archivedAt,
    String? archivedBy,
    String? archivedReason,
    List<MaintenancePhoto>? photos,
  }) = _EquipmentMaintenanceHistory;

  factory EquipmentMaintenanceHistory.fromJson(Map<String, dynamic> json) =>
      _$EquipmentMaintenanceHistoryFromJson(json);
}