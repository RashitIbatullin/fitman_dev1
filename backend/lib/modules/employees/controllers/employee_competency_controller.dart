import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:fitman_backend/modules/employees/services/employee_competency_service.dart';
import 'package:fitman_common/modules/support_staff/competency.model.dart';

class EmployeeCompetencyController {
  EmployeeCompetencyController(this._service);

  final EmployeeCompetencyService _service;

  Future<Response> getCompetencies(Request request, String userId) async {
    final competencies = await _service.getCompetencies(userId);
    return Response.ok(jsonEncode(competencies.map((c) => c.toJson()).toList()),
        headers: {'Content-Type': 'application/json'});
  }

  Future<Response> addCompetency(Request request, String userId) async {
    final body = await request.readAsString();
    final data = jsonDecode(body) as Map<String, dynamic>;
    final competency = Competency.fromJson(data..['competent_id'] = userId);
    final newCompetency = await _service.addCompetency(competency);
    return Response(HttpStatus.created,
        body: jsonEncode(newCompetency.toJson()),
        headers: {'Content-Type': 'application/json'});
  }

  Future<Response> deleteCompetency(
      Request request, String userId, String competencyId) async {
    await _service.deleteCompetency(competencyId);
    return Response(HttpStatus.noContent);
  }
}
