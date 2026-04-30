import 'dart:io';
import 'package:path/path.dart' as path; // Add this import

import 'package:fitman_backend/modules/equipment/repositories/equipment_item.repository.dart';
import 'package:fitman_backend/modules/rooms/repositories/room_repository.dart';
import 'package:fitman_common/modules/rooms/room_model.dart';

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
    // 1. Create a unique filename
    final fileExtension = fileName.split('.').last;
    final uniqueFileName = '${DateTime.now().millisecondsSinceEpoch}_$roomId.$fileExtension';
    
    // The actual directory where files are served from, as configured in server.dart
    // Directory.current.path is 'C:\Android\PROJ\fitman_dev1\backend' when server runs from backend
    final scriptPath = Platform.script.toFilePath(windows: Platform.isWindows);
    final projectRoot = path.normalize(path.join(path.dirname(scriptPath), '..', '..'));
    final absoluteUploadBaseDir = path.join(projectRoot, 'uploads');
    final absoluteRoomPhotosDir = path.join(absoluteUploadBaseDir, 'room_photos');
    final absoluteFilePath = path.join(absoluteRoomPhotosDir, uniqueFileName);

    print('RoomService: uniqueFileName: $uniqueFileName'); // LOG
    print('RoomService: absoluteUploadBaseDir: $absoluteUploadBaseDir'); // LOG
    print('RoomService: absoluteRoomPhotosDir: $absoluteRoomPhotosDir'); // LOG
    print('RoomService: absoluteFilePath: $absoluteFilePath'); // LOG

    // 2. Save the file
    final file = File(absoluteFilePath);
    await file.parent.create(recursive: true); // Ensure directory exists
    await file.writeAsBytes(fileBytes);
    print('RoomService: File successfully written to: $absoluteFilePath'); // LOG

    // 3. Update the database and return public URL
    final publicUrl = '/uploads/room_photos/$uniqueFileName';
    print('RoomService: publicUrl (returned to frontend): $publicUrl'); // LOG
    await _roomRepository.addPhotoUrl(roomId, publicUrl);

    return publicUrl;
  }

  // ADDED METHOD
  Future<void> removeRoomPhoto(String roomId, String photoUrl) async {
    // Remove from DB
    await _roomRepository.removePhotoUrl(roomId, photoUrl);
    
    // Attempt to delete the physical file from the file system
    final scriptPath = Platform.script.toFilePath(windows: Platform.isWindows);
    final projectRoot = path.normalize(path.join(path.dirname(scriptPath), '..', '..'));
    final absoluteUploadBaseDir = path.join(projectRoot, 'uploads');
    // photoUrl is like /uploads/room_photos/filename.jpg
    // need to convert it to room_photos/filename.jpg
    final relativeFilePath = photoUrl.replaceFirst('/uploads/', ''); 
    final absoluteFilePath = path.join(absoluteUploadBaseDir, relativeFilePath);
    
    final file = File(absoluteFilePath);
    if (await file.exists()) {
      try {
        await file.delete();
        print('RoomService: Physical file deleted: $absoluteFilePath');
      } catch (e) {
        print('RoomService: Error deleting physical file $absoluteFilePath: $e');
        // Log the error but don't rethrow, as DB record is already gone.
      }
    } else {
      print('RoomService: Physical file not found at $absoluteFilePath');
    }
  }
}
