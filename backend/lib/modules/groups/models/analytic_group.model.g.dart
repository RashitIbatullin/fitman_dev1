// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytic_group.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnalyticGroup _$AnalyticGroupFromJson(Map<String, dynamic> json) =>
    AnalyticGroup(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String,
      description: json['description'] as String?,
      type: const AnalyticGroupTypeConverter().fromJson(
        (json['type'] as num).toInt(),
      ),
      isAutoUpdate: json['is_auto_update'] as bool? ?? false,
      conditions: json['conditions'] == null
          ? const []
          : _conditionsFromJson(json['conditions']),
      clientIds: json['client_ids_cache'] == null
          ? const []
          : _clientIdsFromJson(json['client_ids_cache']),
      lastUpdatedAt: _nullableDateTimeFromJson(json['last_updated_at']),
      metadata: json['metadata'] as Map<String, dynamic>?,
      companyId: (json['company_id'] as num?)?.toInt(),
      createdAt: _nullableDateTimeFromJson(json['created_at']),
      updatedAt: _nullableDateTimeFromJson(json['updated_at']),
      createdBy: (json['created_by'] as num?)?.toInt(),
      updatedBy: (json['updated_by'] as num?)?.toInt(),
      archivedAt: _nullableDateTimeFromJson(json['archived_at']),
      archivedBy: (json['archived_by'] as num?)?.toInt(),
    );

Map<String, dynamic> _$AnalyticGroupToJson(AnalyticGroup instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'type': const AnalyticGroupTypeConverter().toJson(instance.type),
      'is_auto_update': instance.isAutoUpdate,
      'conditions': instance.conditions,
      'client_ids_cache': instance.clientIds,
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
