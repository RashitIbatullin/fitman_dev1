import 'package:fitman_app/modules/supportStaff/models/competency.model.dart';
import 'package:fitman_app/services/api/support_staff_api.dart';
import 'package:fitman_app/modules/supportStaff/models/support_staff.model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'support_staff_provider.g.dart';

final supportStaffFilterIncludeArchivedProvider =
    StateProvider<bool>((ref) => false);

@riverpod
Future<List<SupportStaff>> allSupportStaff(Ref ref) {
  final includeArchived = ref.watch(supportStaffFilterIncludeArchivedProvider);
  return SupportStaffApi().getAll(includeArchived: includeArchived);
}

@riverpod
Future<SupportStaff> supportStaffById(Ref ref, String id) {
  return SupportStaffApi().getById(id);
}

@Riverpod(keepAlive: true)
class SupportStaffNotifier extends _$SupportStaffNotifier {
  @override
  Future<void> build() async {
    return;
  }

  Future<void> archive(String id, String reason) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await SupportStaffApi().archive(id, reason);
      ref.invalidate(allSupportStaffProvider);
      ref.invalidate(supportStaffByIdProvider(id));
    });
  }

  Future<void> unarchive(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await SupportStaffApi().unarchive(id);
      ref.invalidate(allSupportStaffProvider);
      ref.invalidate(supportStaffByIdProvider(id));
    });
  }

  Future<void> addCompetency(String staffId, Competency competency) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await SupportStaffApi().addCompetency(staffId, competency);
      ref.invalidate(allSupportStaffProvider);
      ref.invalidate(supportStaffByIdProvider(staffId));
    });
  }

  Future<void> deleteCompetency(String staffId, String competencyId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await SupportStaffApi().deleteCompetency(staffId, competencyId);
      ref.invalidate(allSupportStaffProvider);
      ref.invalidate(supportStaffByIdProvider(staffId));
    });
  }
}

