import 'package:fitman_common/modules/support_staff/competency.model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:fitman_app/services/api_service.dart';

part 'competency_provider.g.dart';

@riverpod
class EmployeeCompetencies extends _$EmployeeCompetencies {
  @override
  Future<List<Competency>> build(String employeeId) async {
    return ApiService.getEmployeeCompetencies(employeeId);
  }

  Future<void> addCompetency(Competency competency) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ApiService.addEmployeeCompetency(employeeId, competency);
      return build(employeeId);
    });
  }

  Future<void> deleteCompetency(String competencyId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ApiService.deleteEmployeeCompetency(employeeId, competencyId);
      return build(employeeId);
    });
  }
}
