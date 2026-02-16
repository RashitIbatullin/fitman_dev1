import 'package:fitman_app/services/api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/building/building.model.dart';
import '../../screens/building/buildings_list_screen.dart';

class BuildingsNotifier extends AsyncNotifier<List<Building>> {
  @override
  Future<List<Building>> build() async {
    final isArchived = ref.watch(buildingIsArchivedFilterProvider);
    return ApiService.getAllBuildings(isArchived: isArchived);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build());
  }
}

final allBuildingsProvider =
    AsyncNotifierProvider<BuildingsNotifier, List<Building>>(() {
  return BuildingsNotifier();
});