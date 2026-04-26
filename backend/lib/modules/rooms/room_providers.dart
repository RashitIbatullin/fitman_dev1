import 'package:fitman_backend/config/database.dart';
import 'package:fitman_backend/modules/rooms/repositories/room_repository.dart';
import 'package:fitman_backend/modules/rooms/repositories/room_schedule_repository.dart';
import 'package:fitman_backend/modules/rooms/services/room_service.dart';
import 'package:fitman_backend/modules/equipment/repositories/equipment_item.repository.dart'; // Needed for RoomService
import 'package:fitman_backend/modules/rooms/services/room_schedule_service.dart';

class RoomProviders {
  // Use a singleton pattern for RoomProviders to ensure single instances of its services/repositories
  static final RoomProviders _instance = RoomProviders._internal();
  factory RoomProviders() => _instance;

  late final RoomScheduleRepository roomScheduleRepository;
  late final RoomRepository roomRepository;
  late final EquipmentItemRepository equipmentItemRepository;
  late final RoomService roomService;
  late final RoomScheduleService roomScheduleService;

  RoomProviders._internal() {
    // Initialize dependencies using the global Database singleton
    final db = Database(); // Access the global Database singleton

    roomScheduleRepository = RoomScheduleRepositoryImpl(db);
    roomRepository = RoomRepositoryImpl(db, roomScheduleRepository);
    equipmentItemRepository = EquipmentItemRepositoryImpl(db); // Assume this is available globally or needs instantiation here
    roomService = RoomService(roomRepository, equipmentItemRepository);
    roomScheduleService = RoomScheduleService(roomScheduleRepository);
  }
}
