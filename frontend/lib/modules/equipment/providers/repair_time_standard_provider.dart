import 'package:fitman_common/modules/equipment/repair_time_standard.model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitman_app/services/api/maintenance_api.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'repair_time_standard_provider.g.dart';

// Provider for the MaintenanceApiService
final maintenanceApiServiceProvider = Provider<MaintenanceApiService>((ref) {
  return MaintenanceApiService();
});

// --- Filters for Repair Time Standards ---
final repairTimeStandardFilterIncludeArchivedProvider = StateProvider<bool>((ref) => false);

// --- Repair Time Standard Notifier Provider ---

@riverpod
class RepairTimeStandardNotifier extends _$RepairTimeStandardNotifier {
  @override
  Future<void> build() async {
    return;
  }

  Future<void> createStandard(RepairTimeStandard standard) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(maintenanceApiServiceProvider).createRepairTimeStandard(standard);
      ref.invalidate(allRepairTimeStandardsProvider);
    });
  }

  Future<void> updateStandard(String id, RepairTimeStandard standard) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(maintenanceApiServiceProvider).updateRepairTimeStandard(id, standard);
      ref.invalidate(allRepairTimeStandardsProvider);
    });
  }

  Future<void> archiveStandard(String id, String reason) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(maintenanceApiServiceProvider).archiveRepairTimeStandard(id, reason);
      ref.invalidate(allRepairTimeStandardsProvider);
    });
  }

  Future<void> unarchiveStandard(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(maintenanceApiServiceProvider).unarchiveRepairTimeStandard(id);
      ref.invalidate(allRepairTimeStandardsProvider);
    });
  }
}

// --- Repair Time Standard Providers ---

// All repair time standards provider
final allRepairTimeStandardsProvider =
    FutureProvider<List<RepairTimeStandard>>((ref) async {
  final includeArchived = ref.watch(repairTimeStandardFilterIncludeArchivedProvider);
  return ref.watch(maintenanceApiServiceProvider).getRepairTimeStandards(includeArchived: includeArchived);
});

// Repair time standard by ID provider
final repairTimeStandardByIdProvider =
    FutureProvider.family<RepairTimeStandard, String>((ref, id) async {
  // This is not efficient as it refetches all standards, but it's a simple way to get a single standard
  // A better approach would be to have a dedicated API endpoint for getting a single standard by ID
  final standards = await ref.watch(allRepairTimeStandardsProvider.future);
  return standards.firstWhere((s) => s.id == id);
});
