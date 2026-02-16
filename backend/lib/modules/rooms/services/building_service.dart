import 'package:fitman_backend/modules/rooms/models/building/building.model.dart';
import 'package:fitman_backend/modules/rooms/repositories/building_repository.dart';

class BuildingService {
  const BuildingService(this._buildingRepository);

  final BuildingRepository _buildingRepository;

  Future<List<Building>> getBuildings({bool? isArchived}) {
    return _buildingRepository.selectAll(isArchived: isArchived);
  }

  Future<Building?> getBuildingById(String id) {
    return _buildingRepository.selectById(id);
  }

  Future<Building> createBuilding(Building building) async {
    final existingBuilding = await _buildingRepository.selectByName(building.name);
    if (existingBuilding != null) {
      throw Exception('Building with this name already exists');
    }
    return _buildingRepository.insert(building);
  }

  Future<Building> updateBuilding(String id, Building building, String userId) {
    return _buildingRepository.update(id, building, userId);
  }

  Future<void> deleteBuilding(String id, int userId) {
    return _buildingRepository.archive(id, userId);
  }
}
