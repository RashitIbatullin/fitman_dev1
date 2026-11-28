import 'dart:convert';

import 'package:fitman_backend/audit/audit_context.dart';
import 'package:fitman_backend/errors/app_exception.dart';
import 'package:fitman_backend/modules/services/services/service_purchase_service.dart';
import 'package:fitman_common/fitman_common.dart';
import 'package:shelf/shelf.dart';

/// HTTP-слой оформления услуг, остатков и истории покупок.
class ServicePurchaseController {
  ServicePurchaseController(this._service);

  final ServicePurchaseService _service;

  Future<Response> create(Request request) async {
    final user = _currentUser(request);
    final body = await request.readAsString();
    final data = body.isEmpty
        ? const <String, dynamic>{}
        : jsonDecode(body) as Map<String, dynamic>;

    final clientId = data['clientId']?.toString();
    final serviceId = data['serviceId']?.toString();
    if (clientId == null || !_isUuid(clientId)) {
      throw const ValidationException('Укажите корректный clientId');
    }
    if (serviceId == null || !_isUuid(serviceId)) {
      throw const ValidationException('Укажите корректный serviceId');
    }

    final paymentSource = _optionalInt(data['paymentSource'], 'paymentSource');
    if (paymentSource != null &&
        !const {
          ServicePaymentSource.account,
          ServicePaymentSource.cash,
          ServicePaymentSource.terminal,
          ServicePaymentSource.external1c,
          ServicePaymentSource.none,
          ServicePaymentSource.sbp,
        }.contains(paymentSource)) {
      throw const ValidationException('Неизвестный источник оплаты');
    }

    final paymentStatus = _optionalInt(data['paymentStatus'], 'paymentStatus');
    if (paymentStatus != null &&
        !const {
          ServicePaymentStatus.notRequired,
          ServicePaymentStatus.paid,
          ServicePaymentStatus.debt,
        }.contains(paymentStatus)) {
      throw const ValidationException('Неизвестный статус оплаты');
    }

    final purchase = await _service.create(
      clientId: clientId,
      serviceId: serviceId,
      paymentSource: paymentSource,
      paymentStatus: paymentStatus,
      discount: _optionalDouble(data['discount'], 'discount'),
      discountPercent: _optionalDouble(
        data['discountPercent'],
        'discountPercent',
      ),
      audit: AuditContext.fromRequest(request, user: user),
    );

    return _json(purchase.toJson(), statusCode: 201);
  }

  /// Активирует отложенную покупку. Клиент — только свою, сотрудник — любую.
  Future<Response> activate(Request request, String id) async {
    final user = _currentUser(request);
    final purchase = await _service.getById(id);
    if (purchase == null) {
      throw const NotFoundException('Покупка не найдена');
    }

    final roles = _roles(user);
    final isStaff = roles.contains('admin') || roles.contains('manager');
    if (!isStaff && !(roles.contains('client') && purchase.clientId == user.id)) {
      throw const ForbiddenException('Нет прав на активацию этой покупки');
    }

    final activated = await _service.activate(
      id,
      audit: AuditContext.fromRequest(request, user: user),
    );
    return _json(activated.toJson());
  }

  /// Исправление факта оплаты — только сотрудник.
  Future<Response> update(Request request, String id) async {
    final user = _currentUser(request);
    final body = await request.readAsString();
    final data = body.isEmpty
        ? const <String, dynamic>{}
        : jsonDecode(body) as Map<String, dynamic>;

    final paymentStatus = _optionalInt(data['paymentStatus'], 'paymentStatus');
    if (paymentStatus == null) {
      throw const ValidationException('Укажите статус оплаты');
    }

    final updated = await _service.updatePayment(
      id,
      paymentStatus: paymentStatus,
      paymentSource: _optionalInt(data['paymentSource'], 'paymentSource'),
      audit: AuditContext.fromRequest(request, user: user),
    );
    return _json(updated.toJson());
  }

  /// Ручная архивация покупки — только сотрудник.
  Future<Response> archive(Request request, String id) async {
    final user = _currentUser(request);
    final body = await request.readAsString();
    final data = body.isEmpty
        ? const <String, dynamic>{}
        : jsonDecode(body) as Map<String, dynamic>;
    final reason = data['reason']?.toString() ?? '';

    final archived = await _service.archive(
      id,
      reason: reason,
      audit: AuditContext.fromRequest(request, user: user),
    );
    return _json(archived.toJson());
  }

  /// Возвращает покупку из архива — только сотрудник.
  Future<Response> unarchive(Request request, String id) async {
    final user = _currentUser(request);
    final restored = await _service.unarchive(
      id,
      audit: AuditContext.fromRequest(request, user: user),
    );
    return _json(restored.toJson());
  }

  /// Покупки клиента: клиент видит только свои, менеджер и админ — любые.
  Future<Response> getClientServices(Request request, String clientId) async {
    final user = _currentUser(request);
    _ensureCanViewClient(user, clientId);

    final purchases = await _service.getClientServices(clientId);
    return _json(purchases.map((purchase) => purchase.toJson()).toList());
  }

  /// История покупок.
  Future<Response> getHistory(Request request) async {
    final user = _currentUser(request);
    final query = request.url.queryParameters;

    var clientId = query['clientId'];
    final roles = _roles(user);
    if (roles.contains('admin') || roles.contains('manager')) {
      // Сотрудник видит историю любого клиента и общий список.
    } else if (roles.contains('client')) {
      if (clientId != null && clientId.isNotEmpty && clientId != user.id) {
        throw const ForbiddenException('Клиент может смотреть только свои услуги');
      }
      clientId = user.id;
    } else {
      throw const ForbiddenException('Недостаточно прав для просмотра услуг');
    }

    int? status;
    final rawStatus = query['status'];
    if (rawStatus != null && rawStatus.isNotEmpty) {
      status = int.tryParse(rawStatus);
      if (status == null) {
        throw const ValidationException('Параметр status должен быть числом');
      }
    }

    final purchases = await _service.getHistory(
      clientId: clientId,
      status: status,
    );
    return _json(purchases.map((purchase) => purchase.toJson()).toList());
  }

  void _ensureCanViewClient(User user, String clientId) {
    final roles = _roles(user);
    if (roles.contains('admin') || roles.contains('manager')) {
      return;
    }
    if (roles.contains('client') && user.id == clientId) {
      return;
    }
    throw const ForbiddenException('Клиент может смотреть только свои услуги');
  }

  Set<String> _roles(User user) =>
      user.roles.map((role) => role.name).toSet();

  User _currentUser(Request request) {
    final user = request.context['user'] as User?;
    if (user == null) {
      throw const UnauthorizedException('Требуется авторизация');
    }
    return user;
  }

  int? _optionalInt(Object? value, String field) {
    if (value == null || value.toString().isEmpty) {
      return null;
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
    final parsed = double.tryParse(value.toString());
    if (parsed == null) {
      throw ValidationException('Поле $field должно быть числом');
    }
    return parsed;
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
