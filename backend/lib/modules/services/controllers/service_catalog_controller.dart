import 'dart:convert';

import 'package:fitman_backend/audit/audit_context.dart';
import 'package:fitman_backend/errors/app_exception.dart';
import 'package:fitman_backend/modules/services/repositories/service_repository.dart';
import 'package:fitman_backend/modules/services/services/service_catalog_service.dart';
import 'package:fitman_common/fitman_common.dart';
import 'package:shelf/shelf.dart';

/// HTTP-слой каталога услуг.
class ServiceCatalogController {
  ServiceCatalogController(this._service);

  final ServiceCatalogService _service;

  Future<Response> getAll(Request request) async {
    _currentUser(request);
    final query = request.url.queryParameters;

    final services = await _service.getAll(
      type: query['type'],
      active: _parseBool(query['active'], 'active'),
      archived: _parseBool(query['archived'], 'archived'),
    );

    return _json(services.map((service) => service.toJson()).toList());
  }

  Future<Response> getById(Request request, String id) async {
    _currentUser(request);
    final service = await _service.getById(id);
    if (service == null) {
      throw const NotFoundException('Услуга не найдена');
    }
    return _json(service.toJson());
  }

  Future<Response> getTypes(Request request) async {
    _currentUser(request);
    final types = await _service.getTypes();
    return _json(types);
  }

  Future<Response> getSpecializations(Request request) async {
    _currentUser(request);
    final items = await _service.getSpecializations();
    return _json(items);
  }

  Future<Response> create(Request request) async {
    final user = _currentUser(request);
    final data = await _readBody(request);
    final draft = _parseDraft(data);

    final created = await _service.create(
      draft,
      audit: AuditContext.fromRequest(request, user: user),
    );
    return _json(created.toJson(), statusCode: 201);
  }

  Future<Response> update(Request request, String id) async {
    final user = _currentUser(request);
    if (!_isUuid(id)) {
      throw const ValidationException('Некорректный идентификатор услуги');
    }
    final data = await _readBody(request);
    final draft = _parseDraft(data);

    final updated = await _service.update(
      id,
      draft,
      audit: AuditContext.fromRequest(request, user: user),
    );
    return _json(updated.toJson());
  }

  Future<Response> archive(Request request, String id) async {
    final user = _currentUser(request);
    if (!_isUuid(id)) {
      throw const ValidationException('Некорректный идентификатор услуги');
    }
    final data = await _readBody(request);
    final reason = data['reason']?.toString().trim() ?? '';

    final archived = await _service.archive(
      id,
      reason: reason,
      audit: AuditContext.fromRequest(request, user: user),
    );
    return _json(archived.toJson());
  }

  Future<Response> unarchive(Request request, String id) async {
    final user = _currentUser(request);
    if (!_isUuid(id)) {
      throw const ValidationException('Некорректный идентификатор услуги');
    }

    final restored = await _service.unarchive(
      id,
      audit: AuditContext.fromRequest(request, user: user),
    );
    return _json(restored.toJson());
  }

  Future<Map<String, dynamic>> _readBody(Request request) async {
    final body = await request.readAsString();
    if (body.isEmpty) {
      throw const ValidationException('Тело запроса пустое');
    }
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw const ValidationException('Ожидается JSON-объект');
    }
    return decoded;
  }

  ServiceDraft _parseDraft(Map<String, dynamic> data) {
    final code = data['code']?.toString().trim() ?? '';
    final name = data['name']?.toString().trim() ?? '';
    final serviceTypeId = data['serviceTypeId']?.toString() ?? '';
    if (!_isUuid(serviceTypeId)) {
      throw const ValidationException('Выберите тип услуги');
    }

    final specializationId = data['executorSpecializationId']?.toString();
    if (specializationId != null &&
        specializationId.isNotEmpty &&
        !_isUuid(specializationId)) {
      throw const ValidationException('Некорректная специализация');
    }

    return ServiceDraft(
      code: code,
      name: name,
      description: data['description']?.toString(),
      serviceTypeId: serviceTypeId,
      basePrice: _optionalDouble(data['basePrice'], 'basePrice'),
      currency: data['currency']?.toString() ?? 'RUB',
      durationDays: _optionalInt(data['durationDays'], 'durationDays'),
      usageLimitMode:
          _optionalInt(data['usageLimitMode'], 'usageLimitMode') ??
              ServiceUsageLimitMode.total,
      maxUses: _optionalInt(data['maxUses'], 'maxUses'),
      quotaPeriod: _optionalInt(data['quotaPeriod'], 'quotaPeriod'),
      quotaLimit: _optionalInt(data['quotaLimit'], 'quotaLimit'),
      durationMinutes: _optionalInt(data['durationMinutes'], 'durationMinutes'),
      executorSpecializationId:
          specializationId == null || specializationId.isEmpty
              ? null
              : specializationId,
      activationRequired: _bool(data['activationRequired'], false),
      allowStacking: _bool(data['allowStacking'], true),
      grantsAccess: _bool(data['grantsAccess'], true),
      isActive: _bool(data['isActive'], true),
    );
  }

  User _currentUser(Request request) {
    final user = request.context['user'] as User?;
    if (user == null) {
      throw const UnauthorizedException('Требуется авторизация');
    }
    return user;
  }

  bool? _parseBool(String? value, String field) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (value == 'true' || value == '1') {
      return true;
    }
    if (value == 'false' || value == '0') {
      return false;
    }
    throw ValidationException('Параметр $field должен быть true или false');
  }

  int? _optionalInt(Object? value, String field) {
    if (value == null || value.toString().isEmpty) {
      return null;
    }
    if (value is num) {
      return value.toInt();
    }
    final parsed = int.tryParse(value.toString());
    if (parsed == null) {
      throw ValidationException('Поле $field должно быть числом');
    }
    return parsed;
  }

  double? _optionalDouble(Object? value, String field) {
    if (value == null || value.toString().isEmpty) {
      return null;
    }
    if (value is num) {
      return value.toDouble();
    }
    final parsed = double.tryParse(value.toString());
    if (parsed == null) {
      throw ValidationException('Поле $field должно быть числом');
    }
    return parsed;
  }

  bool _bool(Object? value, bool fallback) {
    if (value is bool) {
      return value;
    }
    if (value == null) {
      return fallback;
    }
    if (value.toString() == 'true') {
      return true;
    }
    if (value.toString() == 'false') {
      return false;
    }
    return fallback;
  }

  bool _isUuid(String value) {
    return RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-'
      r'[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    ).hasMatch(value);
  }

  Response _json(Object data, {int statusCode = 200}) {
    return Response(
      statusCode,
      body: jsonEncode(data),
      headers: {'Content-Type': 'application/json'},
    );
  }
}
