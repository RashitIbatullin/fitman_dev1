
import 'package:fitman_backend/modules/equipment/models/equipment/equipment_item.model.dart';

abstract class MaintenanceService {
  Future<void> scheduleMaintenance(String equipmentId, DateTime date);
  Future<void> completeMaintenance(String equipmentId, String notes);
  Future<List<EquipmentItem>> getItemsRequiringMaintenance();
}

class MaintenanceServiceImpl implements MaintenanceService {
  // MaintenanceServiceImpl(this._equipmentItemRepository);

  // final EquipmentItemRepository _equipmentItemRepository;

  @override
  Future<void> completeMaintenance(String equipmentId, String notes) {
    // TODO: implement completeMaintenance
    throw UnimplementedError();
  }

  @override
  Future<List<EquipmentItem>> getItemsRequiringMaintenance() {
    // TODO: implement getItemsRequiringMaintenance
    throw UnimplementedError();
  }

  @override
  Future<void> scheduleMaintenance(String equipmentId, DateTime date) {
    // TODO: implement scheduleMaintenance
    throw UnimplementedError();
  }
}
