import '../../modules/equipment/models/equipment/equipment_item.model.dart';
import '../../modules/equipment/models/equipment/equipment_type.model.dart';
import '../../modules/equipment/models/equipment/equipment_category.enum.dart';
import '../../modules/equipment/models/equipment_maintenance_history.model.dart';
import '../../modules/rooms/models/building/building.model.dart';
import '../../modules/rooms/models/room/room.model.dart';
import 'base_api.dart';

/// Service class for infrastructure-related APIs (Rooms, Buildings, Equipment).
class InfrastructureApiService extends BaseApiService {
  InfrastructureApiService({super.client});

  // --- Room Methods ---

  Future<List<Room>> getAllRooms(
      {String? buildingId, int? roomType, bool? isActive, bool? isArchived}) async {
    final queryParams = <String, String>{};
    if (buildingId != null) queryParams['buildingId'] = buildingId;
    if (roomType != null) queryParams['roomType'] = roomType.toString();
    if (isActive != null) queryParams['isActive'] = isActive.toString();
    if (isArchived != null) queryParams['isArchived'] = isArchived.toString();

    final data = await get('/api/rooms',
        queryParams: queryParams.isNotEmpty ? queryParams : null);
    return (data as List).map((json) => Room.fromJson(json)).toList();
  }

  Future<Room> getRoomById(String id) async {
    final data = await get('/api/rooms/$id');
    return Room.fromJson(data);
  }

  Future<Room> createRoom(Room room) async {
    final data = await post('/api/rooms', body: room.toJson());
    return Room.fromJson(data);
  }

  Future<Room> updateRoom(String id, Room room) async {
    final data = await put('/api/rooms/$id', body: room.toJson());
    return Room.fromJson(data);
  }

  Future<void> deleteRoom(String id) async {
    await delete('/api/rooms/$id');
  }

  // --- Building Methods ---

  Future<List<Building>> getAllBuildings({bool? isArchived}) async {
    final queryParams = <String, String>{};
    if (isArchived != null) queryParams['isArchived'] = isArchived.toString();

    final data = await get('/api/buildings',
        queryParams: queryParams.isNotEmpty ? queryParams : null);
    return (data as List).map((json) => Building.fromJson(json)).toList();
  }

  Future<Building> getBuildingById(String id) async {
    final data = await get('/api/buildings/$id');
    return Building.fromJson(data);
  }

  Future<Building> createBuilding(Building building) async {
    final data = await post('/api/buildings', body: building.toJson());
    return Building.fromJson(data);
  }

  Future<Building> updateBuilding(String id, Building building) async {
    final data = await put('/api/buildings/$id', body: building.toJson());
    return Building.fromJson(data);
  }

  Future<void> deleteBuilding(String id) async {
    await delete('/api/buildings/$id');
  }

  // --- Equipment Item Methods ---

  Future<List<EquipmentItem>> getAllEquipmentItems(
      {String? roomId, bool? isArchived}) async {
    final queryParams = <String, String>{};
    if (roomId != null) queryParams['roomId'] = roomId;
    if (isArchived != null) {
      queryParams['includeArchived'] = isArchived.toString();
    }

    final data = await get('/api/equipment/items',
        queryParams: queryParams.isNotEmpty ? queryParams : null);
    return (data as List).map((json) => EquipmentItem.fromJson(json)).toList();
  }

  Future<EquipmentItem> getEquipmentItemById(String id) async {
    final data = await get('/api/equipment/items/$id');
    return EquipmentItem.fromJson(data);
  }

  Future<void> archiveEquipmentItem(String id, String reason) async {
    await put('/api/equipment/items/$id/archive',
        body: {'reason': reason});
  }

  Future<void> unarchiveEquipmentItem(String id) async {
    await put('/api/equipment/items/$id/unarchive', body: {});
  }

  Future<EquipmentItem> createEquipmentItem(EquipmentItem equipmentItem) async {
    final data = await post('/api/equipment/items', body: equipmentItem.toJson());
    return EquipmentItem.fromJson(data);
  }

  Future<EquipmentItem> updateEquipmentItem(String id, EquipmentItem equipmentItem) async {
    final data = await put('/api/equipment/items/$id', body: equipmentItem.toJson());
    return EquipmentItem.fromJson(data);
  }

  // --- Equipment Type Methods ---

  Future<List<EquipmentType>> getAllEquipmentTypes(
      {EquipmentCategory? category, bool? isArchived}) async {
    final queryParams = <String, String>{};
    if (category != null) queryParams['category'] = category.index.toString();
    if (isArchived != null) {
      queryParams['includeArchived'] = isArchived.toString();
    }

    final data = await get('/api/equipment/types',
        queryParams: queryParams.isNotEmpty ? queryParams : null);
    return (data as List).map((json) => EquipmentType.fromJson(json)).toList();
  }

  Future<EquipmentType> getEquipmentTypeById(String id) async {
    final data = await get('/api/equipment/types/$id');
    return EquipmentType.fromJson(data);
  }

  Future<EquipmentType> createEquipmentType(
      EquipmentType equipmentType) async {
    final data =
        await post('/api/equipment/types', body: equipmentType.toJson());
    return EquipmentType.fromJson(data);
  }

  Future<EquipmentType> updateEquipmentType(
      String id, EquipmentType equipmentType) async {
    final data =
        await put('/api/equipment/types/$id', body: equipmentType.toJson());
    return EquipmentType.fromJson(data);
  }

  Future<void> deleteEquipmentType(String id) async {
    await delete('/api/equipment/types/$id');
  }

  Future<void> archiveEquipmentType(String id, String reason) async {
    await put('/api/equipment/types/$id/archive',
        body: {'reason': reason});
  }

  Future<void> unarchiveEquipmentType(String id) async {
    await put('/api/equipment/types/$id/unarchive', body: {});
  }

  // --- Maintenance History Methods ---

  Future<List<EquipmentMaintenanceHistory>> getMaintenanceHistory(String itemId) async {
    final data = await get('/api/equipment/maintenance/item/$itemId');
    return (data as List).map((json) => EquipmentMaintenanceHistory.fromJson(json)).toList();
  }

  Future<EquipmentMaintenanceHistory> createMaintenanceHistory(EquipmentMaintenanceHistory history) async {
    final data = await post('/api/equipment/maintenance', body: history.toJson());
    return EquipmentMaintenanceHistory.fromJson(data);
  }

  Future<EquipmentMaintenanceHistory> updateMaintenanceHistory(String historyId, EquipmentMaintenanceHistory history) async {
    final data = await put('/api/equipment/maintenance/$historyId', body: history.toJson());
    return EquipmentMaintenanceHistory.fromJson(data);
  }

  Future<void> archiveMaintenanceHistory(String historyId, String reason) async {
    await delete('/api/equipment/maintenance/$historyId', body: {'reason': reason});
  }
}
