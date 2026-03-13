import 'package:fitman_backend/modules/maintenance/models/equipment_maintenance_history.model.dart';
import 'package:fitman_backend/modules/maintenance/repositories/maintenance_repository.dart';

class MaintenanceService {
  MaintenanceService(this._maintenanceRepository);

  final MaintenanceRepository _maintenanceRepository;


  Future<List<EquipmentMaintenanceHistory>> getAll() {
    return _maintenanceRepository.getAll();
  }

  Future<EquipmentMaintenanceHistory> getById(String id) {
    return _maintenanceRepository.getById(id);
  }

  Future<List<EquipmentMaintenanceHistory>> getByEquipmentItemId(String equipmentItemId, {bool isArchived = false}) {
    return _maintenanceRepository.getByEquipmentItemId(equipmentItemId, isArchived: isArchived);
  }

  Future<EquipmentMaintenanceHistory> create(EquipmentMaintenanceHistory history, String userId) {
    return _maintenanceRepository.create(history, userId);
  }

  Future<EquipmentMaintenanceHistory> update(String id, EquipmentMaintenanceHistory history, String userId) {
    return _maintenanceRepository.update(id, history, userId);
  }

  Future<void> archive(String id, String reason, String userId) {
    return _maintenanceRepository.archive(id, reason, userId);
  }

  Future<void> unarchive(String id) {
    return _maintenanceRepository.unarchive(id);
  }

  Future<void> addPhoto(String maintenanceId, String photoUrl, String comment, String timing, String takenBy) {
    return _maintenanceRepository.addPhoto(maintenanceId, photoUrl, comment, timing, takenBy);
  }
}
