import 'package:fitman_common/fitman_common.dart';

import '../repositories/group_repository.dart';

class GroupService {
  GroupService(this._groupRepository);
  
  final GroupRepository _groupRepository;

  Future<void> moveClient({
    required String clientId,
    required String userRole,
    String? fromGroupId,
    String? toGroupId,
    required String reason,
    required String movedByUserId,
  }) async {
    // Ensure a reason is provided and is sufficient
    if (reason.length < 5) {
      throw ArgumentError('A reason of at least 5 characters is required for the movement.');
    }
    
    // Delegate the entire transactional operation to the repository
    await _groupRepository.moveClient(
      clientId: clientId,
      userRole: userRole,
      fromGroupId: fromGroupId,
      toGroupId: toGroupId,
      reason: reason,
      movedByUserId: movedByUserId,
    );
  }

  Future<List<GroupMovement>> getMovementsForUser(String userId) async {
    return _groupRepository.getMovementsForUser(userId);
  }

  Future<List<GroupMovement>> getMovementsForGroup(String groupId) async {
    return _groupRepository.getMovementsForGroup(groupId);
  }
}
