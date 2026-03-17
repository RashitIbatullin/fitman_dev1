import 'package:fitman_backend/modules/competencies/repositories/competency_repository.dart';
import 'package:fitman_backend/modules/equipment/models/equipment_maintenance_history.model.dart';
import 'package:fitman_backend/modules/supportStaff/models/competency.model.dart';

class EmployeeCompetencyService {
  EmployeeCompetencyService(this._competencyRepository);

  final CompetencyRepository _competencyRepository;

  Future<List<Competency>> getCompetencies(String userId) {
    return _competencyRepository.getCompetencies(userId, ExecutorType.user);
  }

  Future<Competency> addCompetency(Competency competency) {
    return _competencyRepository.addCompetency(competency);
  }

  Future<void> deleteCompetency(String competencyId) {
    return _competencyRepository.deleteCompetency(competencyId);
  }
}
