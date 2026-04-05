// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'equipment_maintenance_history.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MaintenancePhotoImpl _$$MaintenancePhotoImplFromJson(
        Map<String, dynamic> json) =>
    _$MaintenancePhotoImpl(
      id: json['id'] as String,
      maintenanceId: json['maintenance_id'] as String,
      url: json['url'] as String,
      comment: json['comment'] as String?,
      timing: $enumDecode(_$PhotoTimingEnumMap, json['timing']),
      takenAt: json['taken_at'] == null
          ? null
          : DateTime.parse(json['taken_at'] as String),
      takenBy: json['taken_by'] as String?,
    );

Map<String, dynamic> _$$MaintenancePhotoImplToJson(
        _$MaintenancePhotoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'maintenance_id': instance.maintenanceId,
      'url': instance.url,
      'comment': instance.comment,
      'timing': _$PhotoTimingEnumMap[instance.timing]!,
      'taken_at': instance.takenAt?.toIso8601String(),
      'taken_by': instance.takenBy,
    };

const _$PhotoTimingEnumMap = {
  PhotoTiming.before: 'before',
  PhotoTiming.after: 'after',
};

_$EquipmentMaintenanceHistoryImpl _$$EquipmentMaintenanceHistoryImplFromJson(
        Map<String, dynamic> json) =>
    _$EquipmentMaintenanceHistoryImpl(
      id: json['id'] as String?,
      number: json['number'] as String?,
      equipmentItemId: json['equipment_item_id'] as String,
      equipmentName: json['equipment_name'] as String?,
      type: $enumDecode(_$MaintenanceTypeEnumMap, json['type']),
      status: $enumDecode(_$MaintenanceStatusEnumMap, json['status']),
      repairTimeStandardId: json['repair_time_standard_id'] as String?,
      diagnosisNotes: json['diagnosis_notes'] as String?,
      actualDurationHours: (json['actual_duration_hours'] as num?)?.toDouble(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      startedAt: json['started_at'] == null
          ? null
          : DateTime.parse(json['started_at'] as String),
      completedAt: json['completed_at'] == null
          ? null
          : DateTime.parse(json['completed_at'] as String),
      equipmentAvailableFrom: json['equipment_available_from'] == null
          ? null
          : DateTime.parse(json['equipment_available_from'] as String),
      reportedProblem: json['reported_problem'] as String,
      workDescription: json['work_description'] as String?,
      notes: json['notes'] as String?,
      reportedBy: json['reported_by'] as String,
      reportedByName: json['reported_by_name'] as String?,
      inProgressBy: json['in_progress_by'] as String?,
      inProgressByName: json['in_progress_by_name'] as String?,
      completedBy: json['completed_by'] as String?,
      completedByName: json['completed_by_name'] as String?,
      cancelledBy: json['cancelled_by'] as String?,
      cancelledByName: json['cancelled_by_name'] as String?,
      cancelledAt: json['cancelled_at'] == null
          ? null
          : DateTime.parse(json['cancelled_at'] as String),
      cancellationReason: json['cancellation_reason'] as String?,
      executorId: json['executor_id'] as String?,
      executorType: const ExecutorTypeConverter()
          .fromJson((json['executor_type'] as num?)?.toInt()),
      executorName: json['executor_name'] as String?,
      relatedBookingId: json['related_booking_id'] as String?,
      causedDowntime: json['caused_downtime'] as bool? ?? false,
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      archivedAt: json['archived_at'] == null
          ? null
          : DateTime.parse(json['archived_at'] as String),
      archivedBy: json['archived_by'] as String?,
      archivedReason: json['archived_reason'] as String?,
      photos: (json['photos'] as List<dynamic>?)
          ?.map((e) => MaintenancePhoto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$EquipmentMaintenanceHistoryImplToJson(
        _$EquipmentMaintenanceHistoryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'number': instance.number,
      'equipment_item_id': instance.equipmentItemId,
      'equipment_name': instance.equipmentName,
      'type': _$MaintenanceTypeEnumMap[instance.type]!,
      'status': _$MaintenanceStatusEnumMap[instance.status]!,
      'repair_time_standard_id': instance.repairTimeStandardId,
      'diagnosis_notes': instance.diagnosisNotes,
      'actual_duration_hours': instance.actualDurationHours,
      'created_at': instance.createdAt?.toIso8601String(),
      'started_at': instance.startedAt?.toIso8601String(),
      'completed_at': instance.completedAt?.toIso8601String(),
      'equipment_available_from':
          instance.equipmentAvailableFrom?.toIso8601String(),
      'reported_problem': instance.reportedProblem,
      'work_description': instance.workDescription,
      'notes': instance.notes,
      'reported_by': instance.reportedBy,
      'reported_by_name': instance.reportedByName,
      'in_progress_by': instance.inProgressBy,
      'in_progress_by_name': instance.inProgressByName,
      'completed_by': instance.completedBy,
      'completed_by_name': instance.completedByName,
      'cancelled_by': instance.cancelledBy,
      'cancelled_by_name': instance.cancelledByName,
      'cancelled_at': instance.cancelledAt?.toIso8601String(),
      'cancellation_reason': instance.cancellationReason,
      'executor_id': instance.executorId,
      'executor_type':
          const ExecutorTypeConverter().toJson(instance.executorType),
      'executor_name': instance.executorName,
      'related_booking_id': instance.relatedBookingId,
      'caused_downtime': instance.causedDowntime,
      'updated_at': instance.updatedAt?.toIso8601String(),
      'archived_at': instance.archivedAt?.toIso8601String(),
      'archived_by': instance.archivedBy,
      'archived_reason': instance.archivedReason,
      'photos': instance.photos,
    };

const _$MaintenanceTypeEnumMap = {
  MaintenanceType.preventive: 'preventive',
  MaintenanceType.corrective: 'corrective',
};

const _$MaintenanceStatusEnumMap = {
  MaintenanceStatus.reported: 'reported',
  MaintenanceStatus.diagnosing: 'diagnosing',
  MaintenanceStatus.inProgress: 'inProgress',
  MaintenanceStatus.completed: 'completed',
  MaintenanceStatus.cancelled: 'cancelled',
};
