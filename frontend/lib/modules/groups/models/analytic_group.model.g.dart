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
      conditions:
          (json['conditions'] as List<dynamic>?)
              ?.map((e) => GroupCondition.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      clientIds:
          (json['client_ids_cache'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [],
      lastUpdatedAt: json['last_updated_at'] == null
          ? null
          : DateTime.parse(json['last_updated_at'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
      archivedAt: json['archived_at'] == null
          ? null
          : DateTime.parse(json['archived_at'] as String),
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
      'archived_at': instance.archivedAt?.toIso8601String(),
      'archived_by': instance.archivedBy,
    };
