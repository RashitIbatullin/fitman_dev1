import 'package:fitman_backend/modules/equipment/models/booking/equipment_booking.model.dart';
import 'package:fitman_backend/modules/rooms/models/room/room.model.dart';

abstract class AvailabilityService {
  Future<bool> isRoomAvailable(String roomId, DateTime start, DateTime end);
  Future<bool> isEquipmentAvailable(String equipmentId, DateTime start, DateTime end);
  Future<List<EquipmentBooking>> getBookingConflicts(EquipmentBooking booking);
  Future<List<Room>> findAvailableRooms(DateTime start, DateTime end, {int capacity = 1});
}

class AvailabilityServiceImpl implements AvailabilityService {
  @override
  Future<List<EquipmentBooking>> getBookingConflicts(EquipmentBooking booking) {
    // TODO: implement getBookingConflicts
    throw UnimplementedError();
  }

  @override
  Future<List<Room>> findAvailableRooms(DateTime start, DateTime end, {int capacity = 1}) {
    // TODO: implement findAvailableRooms
    throw UnimplementedError();
  }

  @override
  Future<bool> isEquipmentAvailable(String equipmentId, DateTime start, DateTime end) {
    // TODO: implement isEquipmentAvailable
    throw UnimplementedError();
  }

  @override
  Future<bool> isRoomAvailable(String roomId, DateTime start, DateTime end) {
    // TODO: implement isRoomAvailable
    throw UnimplementedError();
  }
}
