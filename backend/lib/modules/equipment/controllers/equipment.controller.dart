import 'dart:convert';

import 'package:fitman_backend/modules/equipment/services/equipment.service.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class EquipmentController {
  EquipmentController(this._equipmentService);

  final EquipmentService _equipmentService;

  Router get router {
    final router = Router();

    router.get('/types', (Request request) async {
      final types = await _equipmentService.getAllTypes();
      return Response.ok(jsonEncode(types));
    });

    router.get('/types/<id>', (Request request, String id) async {
      try {
        final type = await _equipmentService.getTypeById(id);
        return Response.ok(jsonEncode(type));
      } catch (e) {
        return Response.notFound('EquipmentType not found');
      }
    });

    router.get('/items', (Request request) async {
      final items = await _equipmentService.getAllItems();
      return Response.ok(jsonEncode(items));
    });

    router.get('/items/<id>', (Request request, String id) async {
      try {
        final item = await _equipmentService.getItemById(id);
        return Response.ok(jsonEncode(item));
      } catch (e) {
        return Response.notFound('EquipmentItem not found');
      }
    });

    // Other routes will be added here

    return router;
  }
}
