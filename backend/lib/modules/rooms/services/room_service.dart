import 'package:fitman_backend/modules/equipment/repositories/equipment_item.repository.dart';
import 'package:fitman_backend/modules/rooms/repositories/room_repository.dart';
import 'package:fitman_common/modules/rooms/room.model.dart';

class RoomService {
  const RoomService(this._roomRepository, this._equipmentItemRepository);

  final RoomRepository _roomRepository;
  final EquipmentItemRepository _equipmentItemRepository;

  Future<List<Room>> getRooms({bool? isArchived, bool? isActive}) {
    return _roomRepository.getAll(isArchived: isArchived, isActive: isActive);
  }

  Future<Room?> getById(String id) {
    return _roomRepository.getById(id);
  }

  Future<Room> createRoom(Room room) {
    return _roomRepository.create(room);
  }

  Future<Room> updateRoom(String id, Room room) async {
    // If this update is an archival operation (archivedAt is being set), check for equipment.
    if (room.archivedAt != null) {
      final equipmentInRoom =
          await _equipmentItemRepository.getByRoomId(id, includeArchived: false);

      if (equipmentInRoom.isNotEmpty) {
        throw Exception(
            'Нельзя архивировать помещение, в котором есть активное оборудование.');
      }
    }
    return _roomRepository.update(id, room);
  }

  Future<void> archiveRoom(String id, String userId) {
    // Note: This specific method is not used by the frontend, which uses updateRoom.
    // The core logic is now in updateRoom. This is kept for API completeness.
    return _roomRepository.archive(id, userId);
  }
}

