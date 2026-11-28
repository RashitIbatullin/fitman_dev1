import 'package:freezed_annotation/freezed_annotation.dart';

part 'audit_record.model.freezed.dart';
part 'audit_record.model.g.dart';

/// Запись неизменяемого журнала аудита.
@freezed
class AuditRecord with _$AuditRecord {
  const factory AuditRecord({
    required String id,
    required String tableName,
    required String rowPk,
    required String action,
    required DateTime changedAt,
    String? changedBy,
    String? changedByName,
    String? actorRole,
    String? requestId,
    required String source,
    String? reason,
    Map<String, dynamic>? oldValues,
    Map<String, dynamic>? newValues,
  }) = _AuditRecord;

  factory AuditRecord.fromJson(Map<String, dynamic> json) =>
      _$AuditRecordFromJson(json);
}
