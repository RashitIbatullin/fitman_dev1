import 'dart:convert';

import 'package:fitman_backend/modules/equipment/services/booking.service.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class BookingController {
  BookingController(this._bookingService);

  final BookingService _bookingService;

  Router get router {
    final router = Router();

    router.get('/equipment', (Request request) async {
      final bookings = await _bookingService.getAll();
      return Response.ok(jsonEncode(bookings));
    });

    router.get('/equipment/<id>', (Request request, String id) async {
      try {
        final booking = await _bookingService.getById(id);
        return Response.ok(jsonEncode(booking));
      } catch (e) {
        return Response.notFound('Booking not found');
      }
    });

    // Other routes will be added here

    return router;
  }
}
