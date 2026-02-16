import 'package:fitman_app/modules/supportStaff/models/competency.model.dart';
import 'package:fitman_app/modules/supportStaff/models/support_staff.model.dart';

import 'base_api.dart';

class SupportStaffApi extends BaseApiService {
  SupportStaffApi({super.client});

  Future<List<SupportStaff>> getAll({bool? includeArchived}) async {
    final queryParams = <String, String>{};
    if (includeArchived != null) queryParams['includeArchived'] = includeArchived.toString();

    final data = await get('/api/support-staff',
        queryParams: queryParams.isNotEmpty ? queryParams : null);
    return (data as List).map((json) => SupportStaff.fromJson(json)).toList();
  }

  Future<SupportStaff> getById(String id) async {
    final data = await get('/api/support-staff/$id');
    return SupportStaff.fromJson(data);
  }

  Future<SupportStaff> create(SupportStaff staff) async {
    final data = await post('/api/support-staff', body: staff.toJson());
    return SupportStaff.fromJson(data);
  }

  Future<SupportStaff> update(String id, SupportStaff staff) async {
    final data = await put('/api/support-staff/$id', body: staff.toJson());
    return SupportStaff.fromJson(data);
  }

  Future<void> archive(String id, String reason) async {
    await delete('/api/support-staff/$id', body: {'reason': reason});
  }

  Future<void> unarchive(String id) async {
    await put('/api/support-staff/$id/unarchive', body: {});
  }

  Future<List<Competency>> getCompetencies(String staffId) async {
    final data = await get('/api/support-staff/$staffId/competencies');
    return (data as List).map((json) => Competency.fromJson(json)).toList();
  }

  Future<Competency> addCompetency(String staffId, Competency competency) async {
    final data = await post('/api/support-staff/$staffId/competencies',
        body: competency.toJson());
    return Competency.fromJson(data);
  }

  Future<void> deleteCompetency(String staffId, String competencyId) async {
    await delete('/api/support-staff/$staffId/competencies/$competencyId');
  }
}
