import 'package:fitman_backend/modules/equipment/repositories/equipment_item.repository.dart';
import 'package:fitman_backend/modules/rooms/repositories/room_repository.dart';
import 'package:fitman_common/modules/rooms/room_model.dart';

import 'package:fitman_backend/services/photo_service.dart';

class RoomService {
  RoomService(this._roomRepository, this._equipmentItemRepository);

  final RoomRepository _roomRepository;
  final EquipmentItemRepository _equipmentItemRepository;
  final PhotoService _photoService = PhotoService();

  Future<List<Room>> getRooms({bool? isArchived, bool? isActive}) {
    return _roomRepository.getAll(isArchived: isArchived, isActive: isActive);
  }

  Future<Room?> getById(String id) {
    return _roomRepository.getById(id);
  }

  Future<Room> createRoom(Room room, {String? createdBy}) {
    return _roomRepository.create(room, createdBy: createdBy);
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

  Future<String> uploadPhoto({
    required String roomId,
    required String fileName,
    required List<int> fileBytes,
  }) async {
    final publicUrl = await _photoService.savePhoto(
      subDirectory: 'room_photos',
      fileName: fileName,
      fileBytes: fileBytes,
    );
    await _roomRepository.addPhotoUrl(roomId, publicUrl);
    return publicUrl;
  }

  Future<void> removeRoomPhoto(String roomId, String photoUrl) async {
    await _roomRepository.removePhotoUrl(roomId, photoUrl);
    await _photoService.deletePhotoFile(photoUrl);
  }
}
