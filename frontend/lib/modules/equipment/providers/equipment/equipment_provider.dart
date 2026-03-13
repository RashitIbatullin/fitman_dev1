import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitman_app/services/api_service.dart';
import 'package:fitman_app/modules/equipment/models/equipment/equipment_item.model.dart';
import 'package:fitman_app/modules/equipment/models/equipment/equipment_type.model.dart';
import 'package:fitman_app/modules/equipment/models/equipment/equipment_status.enum.dart';
import 'package:fitman_app/modules/equipment/models/equipment/equipment_category.enum.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'equipment_provider.g.dart';


// --- Filters for Equipment ---
final equipmentFilterSearchQueryProvider = StateProvider<String>((ref) => '');
final equipmentFilterEquipmentTypeProvider =
    StateProvider<EquipmentType?>((ref) => null);
final equipmentFilterStatusProvider =
    StateProvider<EquipmentStatus?>((ref) => null);
final equipmentFilterRoomIdProvider = StateProvider<String?>((ref) => null);
final equipmentFilterConditionRatingProvider = StateProvider<int?>((ref) => null);
final equipmentFilterCategoryProvider =
    StateProvider<EquipmentCategory?>((ref) => null);
final equipmentItemFilterIncludeArchivedProvider = StateProvider<bool>((ref) => false);
final equipmentTypeFilterIncludeArchivedProvider = StateProvider<bool>((ref) => false);

// --- Main Equipment Notifier Provider ---

@riverpod
class Equipment extends _$Equipment {
  @override
  Future<void> build() async {
    return;
  }

  Future<void> archiveType(String id, String reason) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ApiService.archiveEquipmentType(id, reason);
      ref.invalidate(allEquipmentTypesProvider);
    });
  }

  Future<void> unarchiveType(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ApiService.unarchiveEquipmentType(id);
      ref.invalidate(allEquipmentTypesProvider);
    });
  }

  Future<void> archiveItem(String id, String reason) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ApiService.archiveEquipmentItem(id, reason);
      ref.invalidate(allEquipmentItemsProvider);
    });
  }

  Future<void> unarchiveItem(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ApiService.unarchiveEquipmentItem(id);
      ref.invalidate(allEquipmentItemsProvider);
    });
  }

}

// --- Equipment Type Providers ---

// All equipment types provider
final allEquipmentTypesProvider =
    FutureProvider<List<EquipmentType>>((ref) async {
  final category = ref.watch(equipmentFilterCategoryProvider);
  final isArchived = ref.watch(equipmentTypeFilterIncludeArchivedProvider); // Use specific filter for types
  return ApiService.getAllEquipmentTypes(
      category: category, isArchived: isArchived);
});

// Equipment type by ID provider
final equipmentTypeByIdProvider =
    FutureProvider.family<EquipmentType, String>((ref, id) async {
  return ApiService.getEquipmentTypeById(id);
});

// Provider that fetches only active equipment types, ignoring filters
final activeEquipmentTypesProvider =
    FutureProvider<List<EquipmentType>>((ref) async {
  return ApiService.getAllEquipmentTypes(isArchived: false);
});

// --- Equipment Item Providers ---

// All equipment items provider
final allEquipmentItemsProvider =
    FutureProvider<List<EquipmentItem>>((ref) async {
  final roomId = ref.watch(equipmentFilterRoomIdProvider);
  final isArchived = ref.watch(equipmentItemFilterIncludeArchivedProvider); // Use specific filter for items
  return ApiService.getAllEquipmentItems(roomId: roomId, isArchived: isArchived);
});

// Equipment item by ID provider
final equipmentItemByIdProvider =
    FutureProvider.family<EquipmentItem, String>((ref, id) async {
  return ApiService.getEquipmentItemById(id);
});
