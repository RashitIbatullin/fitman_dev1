// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audit_record.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AuditRecordImpl _$$AuditRecordImplFromJson(Map<String, dynamic> json) =>
    _$AuditRecordImpl(
      id: json['id'] as String,
      tableName: json['table_name'] as String,
      rowPk: json['row_pk'] as String,
      action: json['action'] as String,
      changedAt: DateTime.parse(json['changed_at'] as String),
      changedBy: json['changed_by'] as String?,
      changedByName: json['changed_by_name'] as String?,
      actorRole: json['actor_role'] as String?,
      requestId: json['request_id'] as String?,
      source: json['source'] as String,
      reason: json['reason'] as String?,
      oldValues: json['old_values'] as Map<String, dynamic>?,
      newValues: json['new_values'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$AuditRecordImplToJson(_$AuditRecordImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'table_name': instance.tableName,
      'row_pk': instance.rowPk,
      'action': instance.action,
      'changed_at': instance.changedAt.toIso8601String(),
      'changed_by': instance.changedBy,
      'changed_by_name': instance.changedByName,
      'actor_role': instance.actorRole,
      'request_id': instance.requestId,
      'source': instance.source,
      'reason': instance.reason,
      'old_values': instance.oldValues,
      'new_values': instance.newValues,
    };
