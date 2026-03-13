import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitman_app/services/api_service.dart';
import 'package:fitman_app/modules/maintenance/models/equipment_maintenance_history.model.dart';

part 'maintenance_provider.g.dart';

@riverpod
class Maintenance extends _$Maintenance {
  @override
  Future<void> build() async {
    return;
  }

  Future<void> createMaintenanceHistory(EquipmentMaintenanceHistory history) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ApiService.createMaintenanceHistory(history);
      ref.invalidate(maintenanceHistoryProvider(history.equipmentItemId));
    });
  }

  Future<void> updateMaintenanceHistory(String historyId, EquipmentMaintenanceHistory history) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ApiService.updateMaintenanceHistory(historyId, history);
      ref.invalidate(maintenanceHistoryProvider(history.equipmentItemId));
    });
  }

  Future<void> archiveMaintenanceHistory(String historyId, String itemId, String reason) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ApiService.archiveMaintenanceHistory(historyId, reason);
      ref.invalidate(maintenanceHistoryProvider(itemId));
      ref.invalidate(allMaintenanceHistoryProvider);
    });
  }

  Future<void> unarchiveMaintenanceHistory(String historyId, String itemId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ApiService.unarchiveMaintenanceHistory(historyId);
      ref.invalidate(maintenanceHistoryProvider(itemId));
      ref.invalidate(allMaintenanceHistoryProvider);
    });
  }
}

final allMaintenanceHistoryProvider =
    FutureProvider<List<EquipmentMaintenanceHistory>>((ref) async {
  return ApiService.getAllMaintenanceHistory();
});

final maintenanceHistoryFilterIncludeArchivedProvider = StateProvider<bool>((ref) => false);

final maintenanceHistoryProvider =
    FutureProvider.family<List<EquipmentMaintenanceHistory>, String>((ref, itemId) async {
  final includeArchived = ref.watch(maintenanceHistoryFilterIncludeArchivedProvider);
  return ApiService.getMaintenanceHistory(itemId, includeArchived: includeArchived);
});
