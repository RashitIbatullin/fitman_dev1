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
        'oldValues': oldValues == null
            ? null
            : jsonEncode(sanitizeSnapshot(oldValues)),
        'newValues': newValues == null
            ? null
            : jsonEncode(sanitizeSnapshot(newValues)),
      },
    );
  }

  /// Маскирует секреты в снимке строки перед записью в `audit_log`.
  ///
  /// ТЗ требует обнулять `password_hash`, `sms_code`, `jwt_refresh_token`.
  /// Маскирование рекурсивное: снимок может содержать вложенные профили.
  static Map<String, Object?> sanitizeSnapshot(Map<String, Object?> values) {
    final result = <String, Object?>{};
    for (final entry in values.entries) {
      result[entry.key] = _sanitizeValue(entry.key, entry.value);
    }
    return result;
  }

  static Object? _sanitizeValue(String key, Object? value) {
    if (_isSecretKey(key)) {
      return '***';
    }
    if (value is Map) {
      final nested = <String, Object?>{};
      for (final entry in value.entries) {
        final nestedKey = entry.key.toString();
        nested[nestedKey] = _sanitizeValue(nestedKey, entry.value);
      }
      return nested;
    }
    if (value is Iterable) {
      return value.map((item) => _sanitizeValue(key, item)).toList();
    }
    return value;
  }

  static bool _isSecretKey(String key) {
    final normalized = key.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    if (normalized.isEmpty) {
      return false;
    }
    return _secretKeys.contains(normalized) ||
        normalized.endsWith('passwordhash') ||
        normalized.endsWith('token');
  }

  static const Set<String> _secretKeys = {
    'password',
    'passwordhash',
    'smscode',
    'jwtrefreshtoken',
    'refreshtoken',
    'accesstoken',
    'token',
    'secret',
    'authorization',
    'cookie',
    'cookies',
  };
}
