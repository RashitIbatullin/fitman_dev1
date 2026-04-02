import 'package:fitman_common/enums/executor_type.dart';
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

extension MaintenanceTypeX on MaintenanceType {
  String get title {
    switch (this) {
      case MaintenanceType.preventive:
        return 'Плановое';
      case MaintenanceType.corrective:
        return 'Ремонт';
    }
  }
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

extension MaintenanceStatusX on MaintenanceStatus {
  String get title {
    switch (this) {
      case MaintenanceStatus.reported:
        return 'Заявка';
      case MaintenanceStatus.inProgress:
        return 'В работе';
      case MaintenanceStatus.completed:
        return 'Завершено';
      case MaintenanceStatus.cancelled:
        return 'Отменено';
    }
  }
  Color get color {
    switch (this) {
      case MaintenanceStatus.reported:
        return Colors.orange; // Problem exists, awaiting action
      case MaintenanceStatus.inProgress:
        return Colors.purple; // Something is happening
      case MaintenanceStatus.completed:
        return Colors.green; // Success
      case MaintenanceStatus.cancelled:
        return Colors.grey; // Neutral
    }
  }
}

/// Фотография ТО
enum PhotoTiming {
  before,
  after,
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

extension ExecutorTypeX on ExecutorType {
  String get title {
    switch (this) {
      case ExecutorType.user:
        return 'Сотрудник';
      case ExecutorType.staff:
        return 'Внешний специалист';
    }
  }
}

@freezed
class EquipmentMaintenanceHistory with _$EquipmentMaintenanceHistory {
  const factory EquipmentMaintenanceHistory({
    String? id,
    String? number,
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
    String? notes,
    required String reportedBy,
    String? reportedByName,
    String? inProgressBy,
    String? inProgressByName,
    String? completedBy,
    String? completedByName,
    String? cancelledBy,
    String? cancelledByName,
    DateTime? cancelledAt,
    String? cancellationReason,
    String? executorId,
    ExecutorType? executorType,
    String? executorName,
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
