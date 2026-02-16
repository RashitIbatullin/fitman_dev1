
import 'package:fitman_backend/modules/equipment/models/booking/equipment_booking.model.dart';
import '../repositories/equipment_booking.repository.dart';

abstract class BookingService {
  Future<EquipmentBooking> getById(String id);
  Future<List<EquipmentBooking>> getAll();
  Future<EquipmentBooking> create(EquipmentBooking equipmentBooking);
  Future<EquipmentBooking> update(EquipmentBooking equipmentBooking);
  Future<void> delete(String id);
}

class BookingServiceImpl implements BookingService {
  BookingServiceImpl(this._bookingRepository);

  final EquipmentBookingRepository _bookingRepository;

  @override
  Future<EquipmentBooking> create(EquipmentBooking equipmentBooking) {
    // TODO: implement logic to check for availability before creating
    return _bookingRepository.create(equipmentBooking);
  }

  @override
  Future<void> delete(String id) {
    return _bookingRepository.delete(id);
  }

  @override
  Future<List<EquipmentBooking>> getAll() {
    return _bookingRepository.getAll();
  }

  @override
  Future<EquipmentBooking> getById(String id) {
    return _bookingRepository.getById(id);
  }

  @override
  Future<EquipmentBooking> update(EquipmentBooking equipmentBooking) {
    return _bookingRepository.update(equipmentBooking);
  }
}
