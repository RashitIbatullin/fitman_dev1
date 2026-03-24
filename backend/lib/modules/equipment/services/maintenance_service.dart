import 'package:fitman_backend/modules/equipment/models/equipment_maintenance_history.model.dart';
import 'package:fitman_backend/modules/equipment/repositories/maintenance_repository.dart';

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
    // When creating, the reported_by should be the creator
    final newHistory = history.copyWith(reportedBy: userId);
    return _maintenanceRepository.create(newHistory, userId);
  }

  Future<EquipmentMaintenanceHistory> update(String id, EquipmentMaintenanceHistory history, String userId) async {
    final oldHistory = await _maintenanceRepository.getById(id);
    var updatedHistory = history;

    // Check if status has changed
    if (oldHistory.status != updatedHistory.status) {
      switch (updatedHistory.status) {
        case MaintenanceStatus.inProgress:
          if (updatedHistory.executorId == null) {
            throw Exception('Cannot move to "In Progress" without an executor.');
          }
          updatedHistory = updatedHistory.copyWith(
            startedAt: DateTime.now(),
            inProgressBy: userId,
          );
          break;
        case MaintenanceStatus.completed:
          updatedHistory = updatedHistory.copyWith(
            completedAt: DateTime.now(),
            completedBy: userId,
          );
          break;
        case MaintenanceStatus.cancelled:
          if (updatedHistory.cancellationReason == null || updatedHistory.cancellationReason!.isEmpty) {
            throw Exception('Cancellation reason is required.');
          }
          updatedHistory = updatedHistory.copyWith(
            cancelledAt: DateTime.now(),
            cancelledBy: userId,
          );
          break;
        case MaintenanceStatus.reported:
        case MaintenanceStatus.diagnosing:
          // Logic for these cases if any
          break;
      }
    }

    return _maintenanceRepository.update(id, updatedHistory, userId);
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

  Future<Map<String, List<Map<String, dynamic>>>> getAvailableExecutors() {
    return _maintenanceRepository.getAvailableExecutors();
  }

  Future<EquipmentMaintenanceHistory> submitDiagnosis({
    required String maintenanceId,
    required String userId,
    required String diagnosisNotes,
    String? repairTimeStandardId,
  }) async {
    final originalHistory = await _maintenanceRepository.getById(maintenanceId);

    final updatedHistory = originalHistory.copyWith(
      diagnosisNotes: diagnosisNotes,
      repairTimeStandardId: repairTimeStandardId,
      status: MaintenanceStatus.inProgress, // After diagnosis, it's ready to be worked on
      startedAt: DateTime.now(), // Diagnosis completion marks the official start of repair
      inProgressBy: userId,
    );

    return _maintenanceRepository.update(maintenanceId, updatedHistory, userId);
  }

  Future<EquipmentMaintenanceHistory> completeRepair({
    required String maintenanceId,
    required String userId,
    required String workDescription,
  }) async {
    final originalHistory = await _maintenanceRepository.getById(maintenanceId);

    final completedAt = DateTime.now();
    final startedAt = originalHistory.startedAt ?? originalHistory.createdAt ?? completedAt;
    final duration = completedAt.difference(startedAt);
    // Round to 2 decimal places
    final actualDurationHours = (duration.inSeconds / 3600 * 100).round() / 100;

    final updatedHistory = originalHistory.copyWith(
      workDescription: workDescription,
      status: MaintenanceStatus.completed,
      completedAt: completedAt,
      completedBy: userId,
      actualDurationHours: actualDurationHours,
    );

    return _maintenanceRepository.update(maintenanceId, updatedHistory, userId);
  }
}
