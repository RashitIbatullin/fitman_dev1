import 'dart:async';
import 'dart:convert';
import 'dart:io'; // Import for HttpStatus

import 'package:shelf/shelf.dart'; // Changed import
import 'package:fitman_backend/modules/supportStaff/models/competency.model.dart';
import 'package:fitman_backend/modules/supportStaff/models/support_staff.model.dart';
import 'package:fitman_backend/modules/supportStaff/services/support_staff.service.dart';

class SupportStaffController {
  SupportStaffController(this._supportStaffService);

  final SupportStaffService _supportStaffService;

  Future<Response> getAll(Request request) async { // Changed Request and Response
    final includeArchived =
        request.url.queryParameters['includeArchived'] == 'true'; // Changed uri to url
    final staff = await _supportStaffService.getAll(
      includeArchived: includeArchived,
    );
    return Response.ok(jsonEncode(staff.map((s) => s.toJson()).toList()), headers: {'Content-Type': 'application/json'}); // Changed Response.json to Response.ok(jsonEncode) and added headers
  }

  Future<Response> getById(Request request, String id) async { // Changed Request and Response
    final staff = await _supportStaffService.getById(id);
    return Response.ok(jsonEncode(staff.toJson()), headers: {'Content-Type': 'application/json'}); // Changed Response.json to Response.ok(jsonEncode) and added headers
  }

  Future<Response> create(Request request) async { // Changed Request and Response
    final body = await request.readAsString(); // Changed request.body() to request.readAsString()
    final data = jsonDecode(body) as Map<String, dynamic>;
    final supportStaff = SupportStaff.fromMap(data);
    final userId = request.headers['X-User-Id'] ?? '1'; // Placeholder for user id
    final newStaff = await _supportStaffService.create(supportStaff, userId);
    return Response(HttpStatus.created, body: jsonEncode(newStaff.toJson()), headers: {'Content-Type': 'application/json'}); // Corrected for created status
  }

  Future<Response> update(Request request, String id) async { // Changed Request and Response
    final body = await request.readAsString(); // Changed request.body() to request.readAsString()
    final data = jsonDecode(body) as Map<String, dynamic>;
    final supportStaff = SupportStaff.fromMap(data);
    final userId = request.headers['X-User-Id'] ?? '1'; // Placeholder for user id
    final updatedStaff =
        await _supportStaffService.update(id, supportStaff, userId);
    return Response.ok(jsonEncode(updatedStaff.toJson()), headers: {'Content-Type': 'application/json'}); // Changed Response.json to Response.ok(jsonEncode) and added headers
  }

  Future<Response> archive(Request request, String id) async { // Changed Request and Response
    final userId = request.headers['X-User-Id'] ?? '1'; // Placeholder for user id
    final body = await request.readAsString();
    final data = jsonDecode(body) as Map<String, dynamic>;
    final reason = data['reason'] as String?;
    await _supportStaffService.archive(id, userId, reason);
    return Response(HttpStatus.noContent); // Corrected to just HttpStatus.noContent
  }

  Future<Response> unarchive(Request request, String id) async { // Changed Request and Response
    await _supportStaffService.unarchive(id);
    return Response(HttpStatus.noContent); // Corrected to just HttpStatus.noContent
  }

  Future<Response> getCompetencies(Request request, String staffId) async { // Changed Request and Response
    final competencies = await _supportStaffService.getCompetencies(staffId);
    return Response.ok(jsonEncode(competencies.map((c) => c.toJson()).toList()), headers: {'Content-Type': 'application/json'}); // Changed Response.json to Response.ok(jsonEncode) and added headers
  }

  Future<Response> addCompetency(Request request, String staffId) async { // Changed Request and Response
    final body = await request.readAsString(); // Changed request.body() to request.readAsString()
    final data = jsonDecode(body) as Map<String, dynamic>;
    final competency = Competency.fromMap(data..['staff_id'] = staffId);
    final newCompetency = await _supportStaffService.addCompetency(competency);
    return Response(HttpStatus.created, body: jsonEncode(newCompetency.toJson()), headers: {'Content-Type': 'application/json'}); // Corrected for created status
  }

  Future<Response> deleteCompetency(
      Request request, String staffId, String competencyId) async { // Changed Request and Response
    await _supportStaffService.deleteCompetency(competencyId);
    return Response(HttpStatus.noContent); // Corrected to just HttpStatus.noContent
  }
}
