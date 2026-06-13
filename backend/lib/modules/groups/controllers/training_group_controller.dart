import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../../config/database.dart';
import 'package:fitman_common/fitman_common.dart';
import 'package:fitman_common/modules/groups/training_group.model.dart';

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

    // Movement routes
    router.post('/move-client', _moveClient);
    router.get('/<id>/movements', _getGroupMovements);
    router.get('/user/<userId>/movements', _getUserMovements);
    
    return router;
  }

  // --- Group Methods ---

  Future<Response> _getAllTrainingGroups(Request request) async {
    try {
      final queryParams = request.url.queryParameters;
      
      // Parse all filter parameters
      final String? searchQuery = queryParams['q'];
      final String? groupTypeId = queryParams['groupTypeId'];
      final bool? isActive = queryParams['isActive'] != null ? bool.parse(queryParams['isActive']!) : null;
      final bool? isArchived = queryParams['isArchived'] != null ? bool.parse(queryParams['isArchived']!) : null;
      final String? trainerId = queryParams['trainerId'];
      final String? instructorId = queryParams['instructorId'];
      final String? managerId = queryParams['managerId'];

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
      final groupId = id;
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
      final user = request.context['user'] as User;
      final creatorId = user.id;
      final newGroup = TrainingGroup.fromJson(payload);
      final createdGroup = await _db.groups.createTrainingGroup(newGroup, creatorId);
      return Response(201, headers: {'Content-Type': 'application/json', 'Location': '/training_groups/${createdGroup.id}'}, body: jsonEncode(createdGroup.toJson()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    }
  }

  Future<Response> _updateTrainingGroup(Request request, String id) async {
    try {
      final groupId = id;
      final payload = jsonDecode(await request.readAsString());
      final user = request.context['user'] as User;
      final updaterId = user.id;
      final updatedGroup = TrainingGroup.fromJson({...payload, 'id': groupId});
      final resultGroup = await _db.groups.updateTrainingGroup(updatedGroup, updaterId);
      return Response.ok(jsonEncode(resultGroup.toJson()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    }
  }

  Future<Response> _deleteTrainingGroup(Request request, String id) async {
    try {
      final groupId = id;
      final user = request.context['user'] as User;
      final archiverId = user.id;
      await _db.groups.deleteTrainingGroup(groupId, archiverId);
      return Response(204);
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    }
  }

  // --- Member Methods ---

  Future<Response> _getTrainingGroupMembers(Request request, String id) async {
    try {
      final groupId = id;
      final members = await _db.groups.getTrainingGroupMembers(groupId);
      return Response.ok(jsonEncode(members));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    }
  }

  Future<Response> _addTrainingGroupMember(Request request, String id) async {
    try {
      final groupId = id;
      final payload = jsonDecode(await request.readAsString());
      final String userId = payload['userId'] as String;
      final user = request.context['user'] as User;
      final addedById = user.id;

      await _db.groups.addTrainingGroupMember(groupId, userId, addedById);
      return Response.ok(jsonEncode({'message': 'Member added successfully'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    }
  }

  Future<Response> _removeTrainingGroupMember(Request request, String id, String userId) async {
    try {
      final gId = id;
      final uId = userId;
      await _db.groups.removeTrainingGroupMember(gId, uId);
      return Response(204);
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    }
  }

  // --- Movement Methods ---

  Future<Response> _moveClient(Request request) async {
    try {
      final user = request.context['user'] as User;
      // Authorization
      if (!user.roles.any((r) => r.name == 'admin' || r.name == 'manager')) {
        return Response.forbidden(jsonEncode({'error': 'Insufficient permissions.'}));
      }
      
      final payload = jsonDecode(await request.readAsString());
      final String clientId = payload['clientId'] as String;
      final String? fromGroupId = payload['fromGroupId'] as String?;
      final String? toGroupId = payload['toGroupId'] as String?;
      final String reason = payload['reason'] as String;
      
      // Basic validation
      if (fromGroupId == null && toGroupId == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Either fromGroupId or toGroupId must be provided.'}));
      }
      if (reason.length < 5) {
        return Response.badRequest(body: jsonEncode({'error': 'A reason of at least 5 characters is required.'}));
      }
      
      await _db.groups.moveClient(
        clientId: clientId,
        fromGroupId: fromGroupId,
        toGroupId: toGroupId,
        reason: reason,
        movedByUserId: user.id,
      );

      return Response.ok(jsonEncode({'message': 'Client moved successfully.'}));
    } on ArgumentError catch (e) {
      return Response.notFound(jsonEncode({'error': e.message}));
    } on StateError catch(e) {
      return Response(409, body: jsonEncode({'error': e.message})); // 409 Conflict
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    }
  }

  Future<Response> _getGroupMovements(Request request, String id) async {
    try {
      // Authorization can be enhanced here later
      final movements = await _db.groups.getMovementsForGroup(id);
      return Response.ok(jsonEncode(movements.map((e) => e.toJson()).toList()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    }
  }

  Future<Response> _getUserMovements(Request request, String userId) async {
    try {
      final user = request.context['user'] as User;
      // Authorization: Allow user to see their own movements, or admin/manager to see anyone's
      if (user.id != userId && !user.roles.any((r) => r.name == 'admin' || r.name == 'manager')) {
        return Response.forbidden(jsonEncode({'error': 'You can only view your own movement history.'}));
      }

      final movements = await _db.groups.getMovementsForUser(userId);
      return Response.ok(jsonEncode(movements.map((e) => e.toJson()).toList()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    }
  }
}
