import 'dart:convert';

import 'package:fitman_backend/audit/audit_context.dart';
import 'package:fitman_backend/modules/appointments/services/appointment_service.dart';
import 'package:fitman_backend/security/access_policy.dart';
import 'package:fitman_common/fitman_common.dart';
import 'package:shelf/shelf.dart';

/// HTTP-слой записей на услуги.
class AppointmentController {
  AppointmentController(this._service);

  final AppointmentService _service;

  Future<Response> getAll(Request request) async {
    final user = _currentUser(request);
    final query = request.url.queryParameters;

    var executorId = query['executorId'];
    // Исполнитель видит только свои записи, остальные роли — любые.
    if (_isExecutorOnly(user)) {
      executorId = user.id;
    }

    final appointments = await _service.getAll(
      from: _parseDate(query['from']),
      to: _parseDate(query['to']),
      executorId: executorId,
      status: int.tryParse(query['status'] ?? ''),
    );

    return _json(
      appointments.map((appointment) => appointment.toJson()).toList(),
    );
  }

  Future<Response> complete(Request request, String id) async {
    final user = _currentUser(request);
    await _service.complete(
      id,
      audit: AuditContext.fromRequest(request, user: user),
    );
    return _json({'status': 'completed'});
  }

  Future<Response> skip(Request request, String id) async {
    final user = _currentUser(request);
    final body = await request.readAsString();
    final data = body.isEmpty
        ? const <String, dynamic>{}
        : jsonDecode(body) as Map<String, dynamic>;

    final party = int.tryParse(data['party']?.toString() ?? '');
    final reason = int.tryParse(data['reason']?.toString() ?? '');
    if (party == null || reason == null) {
      return Response.badRequest(
        body: jsonEncode({
          'error': {
            'code': 'VALIDATION_ERROR',
            'message': 'Нужны сторона пропуска (party) и причина (reason)',
          },
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }

    await _service.skip(
      id,
      party: party,
      reasonCode: reason,
      note: data['note']?.toString(),
      audit: AuditContext.fromRequest(request, user: user),
    );
    return _json({'status': 'skipped'});
  }

  User _currentUser(Request request) {
    final user = request.context['user'] as User?;
    if (user == null) {
      throw StateError('Пользователь не аутентифицирован');
    }
    return user;
  }

  bool _isExecutorOnly(User user) => AccessPolicy.isExecutorOnly(user);

  DateTime? _parseDate(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }

  Response _json(Object data) => Response.ok(
        jsonEncode(data),
        headers: {'Content-Type': 'application/json'},
      );
}
