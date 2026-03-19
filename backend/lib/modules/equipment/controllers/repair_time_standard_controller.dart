import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../models/repair_time_standard.model.dart';
import '../services/repair_time_standard_service.dart';

class RepairTimeStandardController {
  RepairTimeStandardController(this._service);

  final RepairTimeStandardService _service;

  Router get router {
    final router = Router();

    router.get('/', getAll);
    router.post('/', create);
    router.get('/<id>', getById);
    router.put('/<id>', update);
    router.delete('/<id>', archive);

    return router;
  }

  FutureOr<Response> getAll(Request request) async {
    try {
      final standards = await _service.getAll();
      return Response.ok(
        jsonEncode(standards.map((e) => e.toJson()).toList()),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(body: e.toString());
    }
  }

  FutureOr<Response> getById(Request request, String id) async {
    try {
      final standard = await _service.getById(id);
      return Response.ok(
        jsonEncode(standard.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.notFound(e.toString());
    }
  }

  FutureOr<Response> create(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final userId = request.context['user_id'] as String?;
      if (userId == null) {
        return Response.unauthorized('User not authenticated');
      }

      final standard = RepairTimeStandard.fromJson(data);
      final newStandard = await _service.create(standard, userId);
      return Response(
        HttpStatus.created,
        body: jsonEncode(newStandard.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.badRequest(body: e.toString());
    }
  }

  FutureOr<Response> update(Request request, String id) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final userId = request.context['user_id'] as String?;
      if (userId == null) {
        return Response.unauthorized('User not authenticated');
      }

      final standard = RepairTimeStandard.fromJson(data);
      final updatedStandard = await _service.update(id, standard, userId);
      return Response.ok(
        jsonEncode(updatedStandard.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.badRequest(body: e.toString());
    }
  }

  FutureOr<Response> archive(Request request, String id) async {
    try {
      final userId = request.context['user_id'] as String?;
      if (userId == null) {
        return Response.unauthorized('User not authenticated');
      }
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final reason = data['reason'] as String?;
      if (reason == null || reason.isEmpty) {
        return Response.badRequest(body: 'Archived reason is required');
      }
      await _service.archive(id, userId, reason);
      return Response(HttpStatus.noContent);
    } catch (e) {
      return Response.internalServerError(body: e.toString());
    }
  }
}
