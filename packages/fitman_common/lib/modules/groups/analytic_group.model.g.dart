// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytic_group.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnalyticGroup _$AnalyticGroupFromJson(Map<String, dynamic> json) =>
    AnalyticGroup(
      id: json['id'] as String?,
      name: json['name'] as String,
      description: json['description'] as String?,
      type: const AnalyticGroupTypeConverter().fromJson(
        (json['type'] as num).toInt(),
      ),
      isAutoUpdate: json['is_auto_update'] as bool? ?? false,
      conditions: json['conditions'] == null
          ? const []
          : _conditionsFromJson(json['conditions']),
      clientIds: json['client_ids'] == null
          ? const []
          : _clientIdsFromJson(json['client_ids']),
      lastUpdatedAt: _nullableDateTimeFromJson(json['last_updated_at']),
      metadata: json['metadata'] as Map<String, dynamic>?,
      companyId: json['company_id'] as String?,
      createdAt: _nullableDateTimeFromJson(json['created_at']),
      updatedAt: _nullableDateTimeFromJson(json['updated_at']),
      createdBy: json['created_by'] as String?,
      updatedBy: json['updated_by'] as String?,
      archivedAt: _nullableDateTimeFromJson(json['archived_at']),
      archivedBy: json['archived_by'] as String?,
    );

Map<String, dynamic> _$AnalyticGroupToJson(AnalyticGroup instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'type': const AnalyticGroupTypeConverter().toJson(instance.type),
      'is_auto_update': instance.isAutoUpdate,
      'conditions': instance.conditions,
      'client_ids': instance.clientIds,
      'last_updated_at': instance.lastUpdatedAt?.toIso8601String(),
      'metadata': instance.metadata,
      'company_id': instance.companyId,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'created_by': instance.createdBy,
      'updated_by': instance.updatedBy,
      'archived_at': instance.archivedAt?.toIso8601String(),
      'archived_by': instance.archivedBy,
    };
