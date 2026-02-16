import 'package:fitman_backend/modules/equipment/models/booking/equipment_booking.model.dart';

abstract class EquipmentBookingRepository {
  Future<EquipmentBooking> getById(String id);
  Future<List<EquipmentBooking>> getAll();
  Future<EquipmentBooking> create(EquipmentBooking equipmentBooking);
  Future<EquipmentBooking> update(EquipmentBooking equipmentBooking);
  Future<void> delete(String id);
}

class EquipmentBookingRepositoryImpl implements EquipmentBookingRepository {
  // EquipmentBookingRepositoryImpl(this._db);

  // final Connection _db;

  @override
  Future<EquipmentBooking> create(EquipmentBooking equipmentBooking) {
    // TODO: implement create
    throw UnimplementedError();
  }

  @override
  Future<void> delete(String id) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<List<EquipmentBooking>> getAll() {
    // TODO: implement getAll
    throw UnimplementedError();
  }

  @override
  Future<EquipmentBooking> getById(String id) {
    // TODO: implement getById
    throw UnimplementedError();
  }

  @override
  Future<EquipmentBooking> update(EquipmentBooking equipmentBooking) {
    // TODO: implement update
    throw UnimplementedError();
  }
}
