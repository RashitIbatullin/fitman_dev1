import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fitman_common/modules/equipment/equipment_maintenance_history.model.dart';

part 'maintenance_status_history_record.model.freezed.dart';
part 'maintenance_status_history_record.model.g.dart';

@freezed
class MaintenanceStatusHistoryRecord with _$MaintenanceStatusHistoryRecord {
  const factory MaintenanceStatusHistoryRecord({
    required String id,
    required String maintenanceId,
    MaintenanceStatus? oldStatus,
    required MaintenanceStatus newStatus,
    String? comment,
    required DateTime changedAt,
    required String changedBy,
    String? changedByName,
  }) = _MaintenanceStatusHistoryRecord;

  factory MaintenanceStatusHistoryRecord.fromJson(Map<String, dynamic> json) =>
      _$MaintenanceStatusHistoryRecordFromJson(json);
}
