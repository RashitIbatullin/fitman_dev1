// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'maintenance_status_history_record.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MaintenanceStatusHistoryRecordImpl
_$$MaintenanceStatusHistoryRecordImplFromJson(Map<String, dynamic> json) =>
    _$MaintenanceStatusHistoryRecordImpl(
      id: json['id'] as String,
      maintenanceId: json['maintenance_id'] as String,
      oldStatus: $enumDecodeNullable(
        _$MaintenanceStatusEnumMap,
        json['old_status'],
      ),
      newStatus: $enumDecode(_$MaintenanceStatusEnumMap, json['new_status']),
      comment: json['comment'] as String?,
      changedAt: DateTime.parse(json['changed_at'] as String),
      changedBy: json['changed_by'] as String,
      changedByName: json['changed_by_name'] as String?,
    );

Map<String, dynamic> _$$MaintenanceStatusHistoryRecordImplToJson(
  _$MaintenanceStatusHistoryRecordImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'maintenance_id': instance.maintenanceId,
  'old_status': _$MaintenanceStatusEnumMap[instance.oldStatus],
  'new_status': _$MaintenanceStatusEnumMap[instance.newStatus]!,
  'comment': instance.comment,
  'changed_at': instance.changedAt.toIso8601String(),
  'changed_by': instance.changedBy,
  'changed_by_name': instance.changedByName,
};

const _$MaintenanceStatusEnumMap = {
  MaintenanceStatus.reported: 'reported',
  MaintenanceStatus.diagnosing: 'diagnosing',
  MaintenanceStatus.inProgress: 'inProgress',
  MaintenanceStatus.completed: 'completed',
  MaintenanceStatus.cancelled: 'cancelled',
};
