import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:fitman_app/services/api_service.dart';
import '../models/analytic_group.model.dart';
import '../models/training_group.model.dart';
import '../models/training_group_type.model.dart';
import '../models/group_schedule.model.dart';
import 'package:equatable/equatable.dart';

part 'group_providers.g.dart';

// --- Analytic Groups ---

class AnalyticGroupFilter extends Equatable {
  final String searchQuery;
  final bool? isArchived;

  const AnalyticGroupFilter({
    this.searchQuery = '',
    this.isArchived,
  });

  @override
  List<Object?> get props => [searchQuery, isArchived];
}

@Riverpod(keepAlive: true)
class AnalyticGroups extends _$AnalyticGroups {
  @override
  Future<List<AnalyticGroup>> build({
    String searchQuery = '',
    bool? isArchived,
  }) async {
    final allGroups = await ApiService.getAllAnalyticGroups(
      isArchived: isArchived,
    );
    final filteredGroups = allGroups.where((group) {
      final nameMatches = group.name.toLowerCase().contains(searchQuery.toLowerCase());
      return nameMatches;
    }).toList();
    return filteredGroups;
  }

  Future<void> createAnalyticGroup(AnalyticGroup group) async {
    state = const AsyncValue.loading();
    try {
      await ApiService.createAnalyticGroup(group);
      ref.invalidateSelf();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateAnalyticGroup(AnalyticGroup group) async {
    state = const AsyncValue.loading();
    try {
      await ApiService.updateAnalyticGroup(group);
      ref.invalidateSelf();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteAnalyticGroup(int id) async {
    state = const AsyncValue.loading();
    try {
      await ApiService.deleteAnalyticGroup(id);
      ref.invalidateSelf();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

// --- Training Groups ---

class TrainingGroupFilter extends Equatable {
  final String searchQuery;
  final int? groupTypeId;
  final bool? isActive;
  final bool? isArchived;
  final int? trainerId;
  final int? instructorId;
  final int? managerId;

  const TrainingGroupFilter({
    this.searchQuery = '',
    this.groupTypeId,
    this.isActive,
    this.isArchived,
    this.trainerId,
    this.instructorId,
    this.managerId,
  });

  @override
  List<Object?> get props => [searchQuery, groupTypeId, isActive, isArchived, trainerId, instructorId, managerId];
}

@Riverpod(keepAlive: true)
class TrainingGroups extends _$TrainingGroups {
  @override
  Future<List<TrainingGroup>> build({
    String searchQuery = '',
    int? groupTypeId,
    bool? isActive,
    bool? isArchived,
    int? trainerId,
    int? instructorId,
    int? managerId,
  }) async {
    final filteredGroups = await ApiService.getAllTrainingGroups(
      searchQuery: searchQuery,
      groupTypeId: groupTypeId,
      isActive: isActive,
      isArchived: isArchived,
      trainerId: trainerId,
      instructorId: instructorId,
      managerId: managerId,
    );
    return filteredGroups;
  }

  Future<void> createTrainingGroup(TrainingGroup group) async {
    state = const AsyncValue.loading();
    try {
      await ApiService.createTrainingGroup(group);
      ref.invalidateSelf();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateTrainingGroup(TrainingGroup group) async {
    state = const AsyncValue.loading();
    try {
      await ApiService.updateTrainingGroup(group);
      ref.invalidateSelf();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteTrainingGroup(int id) async {
    state = const AsyncValue.loading();
    try {
      await ApiService.deleteTrainingGroup(id);
      ref.invalidateSelf();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

@Riverpod(keepAlive: true)
Future<List<TrainingGroupType>> trainingGroupTypes(Ref ref) async {
  return ApiService.getAllTrainingGroupTypes();
}

// --- Group Schedule ---

@Riverpod(keepAlive: true)
class GroupSchedules extends _$GroupSchedules {
  @override
  Future<List<GroupSchedule>> build(int groupId) async {
    return ApiService.getGroupSchedules(groupId);
  }

  Future<void> createGroupSchedule(GroupSchedule slot) async {
    state = const AsyncValue.loading();
    try {
      await ApiService.createGroupSchedule(slot.groupId, slot);
      ref.invalidateSelf();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateGroupSchedule(GroupSchedule slot) async {
    state = const AsyncValue.loading();
    try {
      await ApiService.updateGroupSchedule(slot);
      ref.invalidateSelf();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteGroupSchedule(int id) async {
    state = const AsyncValue.loading();
    try {
      await ApiService.deleteGroupSchedule(id);
      ref.invalidateSelf();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

// --- Group Members ---

@Riverpod(keepAlive: true)
class GroupMembers extends _$GroupMembers {
  @override
  Future<List<int>> build(int groupId) async {
    return ApiService.getTrainingGroupMembers(groupId);
  }

  Future<void> addMember(int groupId, int userId) async {
    state = const AsyncValue.loading();
    try {
      await ApiService.addTrainingGroupMember(groupId, userId);
      ref.invalidate(trainingGroupsProvider); // Invalidate the main group list
      ref.invalidateSelf();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> removeMember(int groupId, int userId) async {
    state = const AsyncValue.loading();
    try {
      await ApiService.removeTrainingGroupMember(groupId, userId);
      ref.invalidate(trainingGroupsProvider); // Invalidate the main group list
      ref.invalidateSelf();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
