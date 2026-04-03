import 'package:fitman_backend/modules/competencies/repositories/competency_repository.dart';
import 'package:fitman_common/enums/executor_type.dart';
import 'package:fitman_common/modules/support_staff/competency.model.dart';
import 'package:fitman_common/modules/support_staff/support_staff.model.dart';
import 'package:fitman_backend/modules/support_staff/repositories/support_staff.repository.dart';

class SupportStaffService {
  SupportStaffService(this._supportStaffRepository, this._competencyRepository);

  final SupportStaffRepository _supportStaffRepository;
  final CompetencyRepository _competencyRepository;

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
    return _competencyRepository.getCompetencies(staffId, ExecutorType.staff);
  }

  Future<Competency> addCompetency(Competency competency) {
    return _competencyRepository.addCompetency(competency);
  }

  Future<void> deleteCompetency(String competencyId) {
    return _competencyRepository.deleteCompetency(competencyId);
  }
}
