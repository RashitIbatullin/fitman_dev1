import 'package:fitman_common/modules/equipment/equipment/equipment_category.enum.dart';
import 'package:fitman_common/modules/equipment/equipment/equipment_item.model.dart';
import 'package:fitman_common/modules/equipment/equipment/equipment_stats.model.dart';
import 'package:fitman_common/modules/equipment/equipment/equipment_status.enum.dart';
import 'package:fitman_common/modules/equipment/equipment/equipment_type.model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitman_app/services/api_service.dart';

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

// --- Filter for Dashboard ---
final dashboardEquipmentFilterProvider = StateProvider<EquipmentStatus?>((ref) => null);

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
      await ref.read(allEquipmentItemsProvider.future);
    });
  }

  Future<void> unarchiveItem(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ApiService.unarchiveEquipmentItem(id);
      ref.invalidate(allEquipmentItemsProvider);
      await ref.read(allEquipmentItemsProvider.future);
    });
  }

  Future<void> updateItem(EquipmentItem item) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ApiService.updateEquipmentItem(item.id, item);
      ref.invalidate(allEquipmentItemsProvider);
      ref.invalidate(equipmentItemByIdProvider(item.id));
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

// Provider to get all equipment types, including archived, for dropdowns and name maps
final allEquipmentTypesIncludingArchivedProvider =
    FutureProvider<List<EquipmentType>>((ref) async {
  return ApiService.getAllEquipmentTypes(isArchived: null);
});


// --- Equipment Item Providers ---

// All equipment items provider
final allEquipmentItemsProvider =
    FutureProvider<List<EquipmentItem>>((ref) async {
  final roomId = ref.watch(equipmentFilterRoomIdProvider);
  // Always fetch ALL items and let the client-side filtering logic handle what to show.
  return ApiService.getAllEquipmentItems(roomId: roomId, isArchived: null);
});

// Equipment item by ID provider
final equipmentItemByIdProvider =
    FutureProvider.family<EquipmentItem, String>((ref, id) async {
  return ApiService.getEquipmentItemById(id);
});

// --- Equipment Stats Provider ---
@riverpod
EquipmentStats equipmentStats(Ref ref) {
  // By watching the provider that includes archived items, we ensure stats are based on the complete dataset
  final equipmentAsyncValue = ref.watch(allEquipmentItemsProvider);
  
  return equipmentAsyncValue.when(
    data: (items) {
      // If the main filter is set to exclude archived, stats will reflect only active items.
      // This logic assumes the dashboard should reflect the current filter state.
      int total = items.length;
      int available = items.where((item) => item.status == EquipmentStatus.available).length;
      int inUse = items.where((item) => item.status == EquipmentStatus.inUse).length;
      int inMaintenance = items.where((item) => item.status == EquipmentStatus.maintenance).length;
      int outOfOrder = items.where((item) => item.status == EquipmentStatus.outOfOrder).length;
      // Note: This doesn't count 'storage' status from the enum, which might be desired later.

      return EquipmentStats(
        total: total,
        available: available,
        inUse: inUse,
        inMaintenance: inMaintenance,
        outOfOrder: outOfOrder,
      );
    },
    // Provide a default loading state
    loading: () => const EquipmentStats(total: 0, available: 0, inUse: 0, inMaintenance: 0, outOfOrder: 0),
    // Provide a default error state
    error: (err, stack) => const EquipmentStats(total: 0, available: 0, inUse: 0, inMaintenance: 0, outOfOrder: 0),
  );
}

// --- Filtered Equipment List for Dashboard ---
@riverpod
List<EquipmentItem> filteredDashboardEquipment(
    Ref ref) {
  final filter = ref.watch(dashboardEquipmentFilterProvider);
  final equipmentAsync = ref.watch(allEquipmentItemsProvider);

  return equipmentAsync.when(
    data: (items) {
      // First, always filter out archived items for this dashboard view.
      final activeItems = items.where((item) => item.archivedAt == null).toList();

      if (filter == null) {
        return activeItems; // Return all non-archived items
      }
      // Then, apply the status filter to the active items.
      return activeItems.where((item) => item.status == filter).toList();
    },
    loading: () => [],
    error: (e, s) => [],
  );
}
