import 'dart:convert';
import 'package:fitman_app/modules/equipment/models/booking/equipment_booking.model.dart';
import 'package:http/http.dart' as http;

class BookingService {
  final String _baseUrl = 'http://localhost:8080/api/bookings/equipment'; // Placeholder

  Future<List<EquipmentBooking>> getAllBookings() async {
    final response = await http.get(Uri.parse(_baseUrl));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => EquipmentBooking.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load equipment bookings');
    }
  }

  // Other methods will be added here
}
