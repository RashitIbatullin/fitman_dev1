import 'base_api.dart';
import '../../../modules/supportStaff/models/competency.model.dart';

class EmployeeApiService extends BaseApiService {
  Future<List<Competency>> getCompetencies(String userId) async {
    final response = await get('/api/employees/$userId/competencies');
    final data = List<Map<String, dynamic>>.from(response);
    return data.map((item) => Competency.fromJson(item)).toList();
  }

  Future<Competency> addCompetency(String userId, Competency competency) async {
    final response = await post('/api/employees/$userId/competencies', body: competency.toJson());
    return Competency.fromJson(response);
  }

  Future<void> deleteCompetency(String userId, String competencyId) async {
    await delete('/api/employees/$userId/competencies/$competencyId');
  }
}
