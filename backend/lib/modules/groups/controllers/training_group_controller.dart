import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../../config/database.dart';
import '../models/training_group.model.dart';

class TrainingGroupsController {
  final Database _db;

  TrainingGroupsController(this._db);

  Router get router {
    final router = Router();

    router.get('/', _getAllTrainingGroups);
    router.post('/', _createTrainingGroup);
    router.get('/<id>', _getTrainingGroupById);
    router.put('/<id>', _updateTrainingGroup);
    router.delete('/<id>', _deleteTrainingGroup);

    // Member routes
    router.get('/<id>/members', _getTrainingGroupMembers);
    router.post('/<id>/members', _addTrainingGroupMember);
    router.delete('/<id>/members/<userId>', _removeTrainingGroupMember);
    
    return router;
  }

  // --- Group Methods ---

  Future<Response> _getAllTrainingGroups(Request request) async {
    try {
      final queryParams = request.url.queryParameters;
      
      // Parse all filter parameters
      final String? searchQuery = queryParams['q'];
      final int? groupTypeId = queryParams['groupTypeId'] != null ? int.tryParse(queryParams['groupTypeId']!) : null;
      final bool? isActive = queryParams['isActive'] != null ? bool.parse(queryParams['isActive']!) : null;
      final bool? isArchived = queryParams['isArchived'] != null ? bool.parse(queryParams['isArchived']!) : null;
      final int? trainerId = queryParams['trainerId'] != null ? int.tryParse(queryParams['trainerId']!) : null;
      final int? instructorId = queryParams['instructorId'] != null ? int.tryParse(queryParams['instructorId']!) : null;
      final int? managerId = queryParams['managerId'] != null ? int.tryParse(queryParams['managerId']!) : null;

      final groups = await _db.groups.getAllTrainingGroups(
        searchQuery: searchQuery,
        groupTypeId: groupTypeId,
        isActive: isActive,
        isArchived: isArchived,
        trainerId: trainerId,
        instructorId: instructorId,
        managerId: managerId,
      );
      return Response.ok(jsonEncode(groups.map((g) => g.toJson()).toList()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    }
  }

  Future<Response> _getTrainingGroupById(Request request, String id) async {
    try {
      final groupId = int.parse(id);
      final group = await _db.groups.getTrainingGroupById(groupId);
      if (group == null) {
        return Response.notFound(jsonEncode({'error': 'TrainingGroup not found'}));
      }
      return Response.ok(jsonEncode(group.toJson()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    }
  }

  Future<Response> _createTrainingGroup(Request request) async {
    try {
      final payload = jsonDecode(await request.readAsString());
      const creatorId = 1; // Placeholder
      final newGroup = TrainingGroup.fromJson(payload);
      final createdGroup = await _db.groups.createTrainingGroup(newGroup, creatorId);
      return Response(201, headers: {'Content-Type': 'application/json', 'Location': '/training_groups/${createdGroup.id}'}, body: jsonEncode(createdGroup.toJson()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    }
  }

  Future<Response> _updateTrainingGroup(Request request, String id) async {
    try {
      final groupId = int.parse(id);
      final payload = jsonDecode(await request.readAsString());
      const updaterId = 1; // Placeholder
      final updatedGroup = TrainingGroup.fromJson({...payload, 'id': groupId});
      final resultGroup = await _db.groups.updateTrainingGroup(updatedGroup, updaterId);
      return Response.ok(jsonEncode(resultGroup.toJson()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    }
  }

  Future<Response> _deleteTrainingGroup(Request request, String id) async {
    try {
      final groupId = int.parse(id);
      const archiverId = 1; // Placeholder
      await _db.groups.deleteTrainingGroup(groupId, archiverId);
      return Response(204);
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    }
  }

  // --- Member Methods ---

  Future<Response> _getTrainingGroupMembers(Request request, String id) async {
    try {
      final groupId = int.parse(id);
      final members = await _db.groups.getTrainingGroupMembers(groupId);
      return Response.ok(jsonEncode(members));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    }
  }

  Future<Response> _addTrainingGroupMember(Request request, String id) async {
    try {
      final groupId = int.parse(id);
      final payload = jsonDecode(await request.readAsString());
      final int userId = payload['userId'] as int;
      const addedById = 1; // Placeholder

      await _db.groups.addTrainingGroupMember(groupId, userId, addedById);
      return Response.ok(jsonEncode({'message': 'Member added successfully'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    }
  }

  Future<Response> _removeTrainingGroupMember(Request request, String id, String userId) async {
    try {
      final gId = int.parse(id);
      final uId = int.parse(userId);
      await _db.groups.removeTrainingGroupMember(gId, uId);
      return Response(204);
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    }
  }
}