import 'dart:convert';

import 'package:postgres/postgres.dart';

import 'audit_context.dart';

/// Записывает аудит в `audit_log` в переданной транзакции.
class AuditService {
  const AuditService();

  Future<void> record({
    required Session session,
    required String tableName,
    required String rowPk,
    required String action,
    required AuditContext context,
    Map<String, Object?>? oldValues,
    Map<String, Object?>? newValues,
    String? reason,
  }) async {
    await session.execute(
      Sql.named('''
        INSERT INTO audit_log (
          table_name, row_pk, action, changed_by, actor_role,
          request_id, source, reason, old_values, new_values
        ) VALUES (
          @tableName, CAST(@rowPk AS uuid), @action,
          CAST(@changedBy AS uuid), @actorRole,
          CAST(@requestId AS uuid), @source, @reason,
          CAST(@oldValues AS jsonb), CAST(@newValues AS jsonb)
        )
      '''),
      parameters: {
        'tableName': tableName,
        'rowPk': rowPk,
        'action': action,
        'changedBy': context.actorId,
        'actorRole': context.actorRole,
        'requestId': context.requestId,
        'source': context.source,
        'reason': reason,
        'oldValues': oldValues == null ? null : jsonEncode(oldValues),
        'newValues': newValues == null ? null : jsonEncode(newValues),
      },
    );
  }
}
