import 'dart:convert';

import 'package:fitman_backend/errors/app_exception.dart';
import 'package:fitman_backend/modules/services/services/service_catalog_service.dart';
import 'package:fitman_common/fitman_common.dart';
import 'package:shelf/shelf.dart';

/// HTTP-слой каталога услуг (только чтение).
class ServiceCatalogController {
  ServiceCatalogController(this._service);

  final ServiceCatalogService _service;

  Future<Response> getAll(Request request) async {
    _currentUser(request);
    final query = request.url.queryParameters;

    final active = _parseBool(query['active']);
    final services = await _service.getAll(
      type: query['type'],
      active: active,
    );

    return _json(services.map((service) => service.toJson()).toList());
  }

  Future<Response> getTypes(Request request) async {
    _currentUser(request);
    final types = await _service.getTypes();
    return _json(types);
  }

  User _currentUser(Request request) {
    final user = request.context['user'] as User?;
    if (user == null) {
      throw const UnauthorizedException('Требуется авторизация');
    }
    return user;
  }

  bool? _parseBool(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (value == 'true' || value == '1') {
      return true;
    }
    if (value == 'false' || value == '0') {
      return false;
    }
    throw const ValidationException('Параметр active должен быть true или false');
  }

  Response _json(Object data, {int statusCode = 200}) {
    return Response(
      statusCode,
      body: jsonEncode(data),
      headers: {'Content-Type': 'application/json'},
    );
  }
}
