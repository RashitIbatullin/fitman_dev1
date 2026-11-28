import 'dart:convert';

import 'package:fitman_backend/config/database.dart';
import 'package:fitman_common/fitman_common.dart';
import 'package:postgres/postgres.dart';

/// Страница журнала аудита.
class AuditPage {
  const AuditPage({
    required this.items,
    required this.total,
    required this.limit,
    required this.offset,
  });

  final List<AuditRecord> items;
  final int total;
  final int limit;
  final int offset;
}

/// Чтение append-only журнала аудита.
abstract class AuditRepository {
  Future<AuditPage> getPage({
    String? tableName,
    String? action,
    DateTime? from,
    DateTime? to,
    required int limit,
    required int offset,
  });
}

class AuditRepositoryImpl implements AuditRepository {
  AuditRepositoryImpl(this._db);

  final Database _db;

  @override
  Future<AuditPage> getPage({
    String? tableName,
    String? action,
    DateTime? from,
    DateTime? to,
    required int limit,
    required int offset,
  }) async {
    final connection = await _db.connection;
    final where = <String>[];
    final parameters = <String, dynamic>{};

    if (tableName != null && tableName.isNotEmpty) {
      where.add('a.table_name = @tableName');
      parameters['tableName'] = tableName;
    }
    if (action != null && action.isNotEmpty) {
      where.add('a.action = @action');
      parameters['action'] = action;
    }
    if (from != null) {
      where.add('a.changed_at >= @from');
      parameters['from'] = from;
    }
    if (to != null) {
      where.add('a.changed_at < @to');
      parameters['to'] = to;
    }
    final whereClause = where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}';

    final countRows = await connection.execute(
      Sql.named('SELECT COUNT(*) FROM audit_log a $whereClause'),
      parameters: parameters,
    );
    final total = countRows.first[0] as int;

    final rows = await connection.execute(
      Sql.named('''
        SELECT
          a.id,
          a.table_name,
          a.row_pk,
          a.action,
          a.changed_at,
          a.changed_by,
          concat_ws(' ', u.last_name, u.first_name) AS changed_by_name,
          a.actor_role,
          a.request_id,
          a.source,
          a.reason,
          a.old_values,
          a.new_values
        FROM audit_log a
        LEFT JOIN users u ON u.id = a.changed_by
        $whereClause
        ORDER BY a.changed_at DESC, a.id DESC
        LIMIT @limit OFFSET @offset
      '''),
      parameters: {
        ...parameters,
        'limit': limit,
        'offset': offset,
      },
    );

    return AuditPage(
      items: rows.map(_toRecord).toList(),
      total: total,
      limit: limit,
      offset: offset,
    );
  }

  AuditRecord _toRecord(ResultRow row) {
    final map = row.toColumnMap();
    return AuditRecord(
      id: map['id'].toString(),
      tableName: map['table_name'].toString(),
      rowPk: map['row_pk'].toString(),
      action: map['action'].toString(),
      changedAt: map['changed_at'] as DateTime,
      changedBy: map['changed_by']?.toString(),
      changedByName: map['changed_by_name'] as String?,
      actorRole: map['actor_role'] as String?,
      requestId: map['request_id']?.toString(),
      source: map['source'].toString(),
      reason: map['reason'] as String?,
      oldValues: _decodeJson(map['old_values']),
      newValues: _decodeJson(map['new_values']),
    );
  }

  Map<String, dynamic>? _decodeJson(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    if (value is String && value.isNotEmpty) {
      final decoded = jsonDecode(value);
      return decoded is Map ? Map<String, dynamic>.from(decoded) : null;
    }
    return null;
  }
}
