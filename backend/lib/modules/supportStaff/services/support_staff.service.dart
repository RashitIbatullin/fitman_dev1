import 'package:fitman_backend/modules/supportStaff/models/competency.model.dart';
import 'package:fitman_backend/modules/supportStaff/models/support_staff.model.dart';
import 'package:fitman_backend/modules/supportStaff/repositories/support_staff.repository.dart';

class SupportStaffService {
  SupportStaffService(this._supportStaffRepository);

  final SupportStaffRepository _supportStaffRepository;

  Future<List<SupportStaff>> getAll({bool includeArchived = false}) {
    return _supportStaffRepository.getAll(includeArchived: includeArchived);
  }

  Future<SupportStaff> getById(String id) {
    return _supportStaffRepository.getById(id);
  }

  Future<SupportStaff> create(SupportStaff supportStaff, String userId) {
    return _supportStaffRepository.create(supportStaff, userId);
  }

  Future<SupportStaff> update(String id, SupportStaff supportStaff, String userId) {
    return _supportStaffRepository.update(id, supportStaff, userId);
  }

  Future<void> archive(String id, String userId, String? archivedReason) {
    return _supportStaffRepository.archive(id, userId, archivedReason);
  }

  Future<void> unarchive(String id) {
    return _supportStaffRepository.unarchive(id);
  }

  Future<List<Competency>> getCompetencies(String staffId) {
    return _supportStaffRepository.getCompetencies(staffId);
  }

  Future<Competency> addCompetency(Competency competency) {
    return _supportStaffRepository.addCompetency(competency);
  }

  Future<void> deleteCompetency(String competencyId) {
    return _supportStaffRepository.deleteCompetency(competencyId);
  }
}
