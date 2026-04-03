import 'package:fitman_backend/modules/competencies/repositories/competency_repository.dart';
import 'package:fitman_common/enums/executor_type.dart';
import 'package:fitman_common/modules/support_staff/competency.model.dart';

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
