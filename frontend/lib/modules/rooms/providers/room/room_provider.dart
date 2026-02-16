import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitman_app/services/api_service.dart';
import 'package:fitman_app/modules/rooms/models/room/room.model.dart';
import 'package:fitman_app/modules/equipment/models/equipment/equipment_item.model.dart';

import '../../models/room/room_type.enum.dart'; // Needed for equipmentByRoomProvider

// --- Filters for Rooms ---
final roomIsActiveFilterProvider = StateProvider<bool?>((ref) => null);
final roomIsArchivedFilterProvider = StateProvider<bool?>((ref) => null);
final roomTypeFilterProvider = StateProvider<RoomType?>((ref) => null);

// --- Room Providers ---

// All rooms provider
final allRoomsProvider = FutureProvider<List<Room>>((ref) async {
  final isActive = ref.watch(roomIsActiveFilterProvider);
  final isArchived = ref.watch(roomIsArchivedFilterProvider);
  final roomType = ref.watch(roomTypeFilterProvider); // Using roomType filter

  final rooms = await ApiService.getAllRooms(
    isActive: isActive,
    isArchived: isArchived,
    roomType: roomType?.value,
  );
  return rooms;
});

// Room by ID provider
final roomByIdProvider = FutureProvider.family<Room, String>((ref, id) async {
  return ApiService.getRoomById(id);
});

// Equipment by Room provider (assuming this is used in room detail)
final equipmentInRoomProvider =
    FutureProvider.family<List<EquipmentItem>, String>((ref, roomId) async {
  return ApiService.getAllEquipmentItems(roomId: roomId);
});

