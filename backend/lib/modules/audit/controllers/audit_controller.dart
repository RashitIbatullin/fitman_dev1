import 'dart:convert';

import 'package:fitman_backend/errors/app_exception.dart';
import 'package:fitman_backend/modules/audit/services/audit_query_service.dart';
import 'package:fitman_common/fitman_common.dart';
import 'package:shelf/shelf.dart';

/// HTTP-слой чтения журнала аудита (только администратор).
class AuditController {
  AuditController(this._service);

  final AuditQueryService _service;

  Future<Response> getAll(Request request) async {
    _currentUser(request);
    final query = request.url.queryParameters;

    final limit = _optionalInt(query['limit'], 'limit') ?? 50;
    final offset = _optionalInt(query['offset'], 'offset') ?? 0;

    final page = await _service.getPage(
      tableName: query['tableName'],
      action: query['action'],
      from: _optionalDate(query['from'], 'from'),
      to: _optionalDate(query['to'], 'to'),
      limit: limit,
      offset: offset,
    );

    return _json({
      'items': page.items.map((record) => record.toJson()).toList(),
      'total': page.total,
      'limit': page.limit,
      'offset': page.offset,
    });
  }

  User _currentUser(Request request) {
    final user = request.context['user'] as User?;
    if (user == null) {
      throw const UnauthorizedException('Требуется авторизация');
    }
    return user;
  }

  int? _optionalInt(String? value, String field) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final parsed = int.tryParse(value);
    if (parsed == null) {
      throw ValidationException('Параметр $field должен быть числом');
    }
    return parsed;
  }

  DateTime? _optionalDate(String? value, String field) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final parsed = DateTime.tryParse(value);
    if (parsed == null) {
      throw ValidationException('Параметр $field должен быть датой');
    }
    return parsed;
  }

  Response _json(Object data) {
    return Response.ok(
      jsonEncode(data),
      headers: {'Content-Type': 'application/json'},
    );
  }
}
