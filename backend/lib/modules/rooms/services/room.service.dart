import 'package:fitman_backend/modules/rooms/models/room/room.model.dart';
import 'package:fitman_backend/modules/rooms/repositories/room.repository.dart';

class RoomService {
  const RoomService(this._roomRepository);

  final RoomRepository _roomRepository;

  Future<List<Room>> getRooms({bool? isArchived, bool? isActive}) {
    return _roomRepository.getAll(isArchived: isArchived, isActive: isActive);
  }

  Future<Room?> getRoomById(String id) {
    return _roomRepository.getById(id);
  }

  Future<Room> createRoom(Room room) {
    return _roomRepository.create(room);
  }

  Future<Room> updateRoom(String id, Room room) {
    return _roomRepository.update(id, room);
  }

  Future<void> archiveRoom(String id, String userId) {
    return _roomRepository.archive(id, userId);
  }
}
