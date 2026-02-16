import 'package:fitman_app/modules/equipment/models/equipment/equipment_status.enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitman_app/modules/rooms/providers/room/room_provider.dart';
import 'package:intl/intl.dart'; // Added for DateFormat
import '../../models/room/room.model.dart';
import '../../utils/room_utils.dart';
import 'room_edit_screen.dart'; // Import the edit screen

class RoomDetailScreen extends ConsumerWidget {
  const RoomDetailScreen({super.key, required this.roomId});

  final String roomId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomAsync = ref.watch(roomByIdProvider(roomId));

    return Scaffold(
      appBar: AppBar(
        title: roomAsync.when(
          data: (room) => Text(room.name),
          loading: () => const Text('Загрузка...'),
          error: (err, stack) => const Text('Ошибка'),
        ),
        actions: [
          roomAsync.when(
            data: (room) => IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RoomEditScreen(room: room),
                  ),
                ).then((_) {
                  // Refresh room data when returning from edit screen
                  ref.invalidate(roomByIdProvider(roomId));
                });
              },
              tooltip: 'Редактировать',
            ),
            loading: () => const SizedBox.shrink(),
            error: (err, stack) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: roomAsync.when(
        data: (room) => _buildRoomDetails(context, ref, room),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Ошибка: $err')),
      ),
    );
  }

  Widget _buildRoomDetails(BuildContext context, WidgetRef ref, Room room) {
    return DefaultTabController(
      length: 5, // Number of tabs
      child: Column(
        children: [
          const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Основное'),
              Tab(text: 'Расписание'),
              Tab(text: 'Состояние'),
              Tab(text: 'Оборудование'),
              Tab(text: 'Статистика'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                // 1. Основное
                _buildMainInfoTab(context, room),
                // 2. Расписание (Placeholder)
                const Center(child: Text('Информация о расписании')),
                // 3. Состояние (Placeholder)
                const Center(child: Text('Информация о состоянии')),
                // 4. Оборудование (Implemented)
                _buildEquipmentTab(context, ref, room.id),
                // 5. Статистика (Placeholder)
                const Center(child: Text('Информация о статистике')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentTab(BuildContext context, WidgetRef ref, String roomId) {
    final equipmentAsync = ref.watch(equipmentInRoomProvider(roomId));

    return equipmentAsync.when(
      data: (equipmentList) {
        if (equipmentList.isEmpty) {
          return const Center(
            child: Text(
              'В этом зале нет оборудования.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: equipmentList.length,
          itemBuilder: (context, index) {
            final item = equipmentList[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4.0),
              child: ListTile(
                leading: const Icon(Icons.fitness_center, color: Colors.blue),
                title: Text(item.model ?? 'Оборудование без модели'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Инв. №: ${item.inventoryNumber}'),
                    if (item.manufacturer != null)
                      Text('Производитель: ${item.manufacturer}'),
                  ],
                ),
                trailing: Text(
                  item.status.displayName,
                  style: TextStyle(
                    color: item.status.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Ошибка загрузки оборудования: $err',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }

  Widget _buildMainInfoTab(BuildContext context, Room room) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TODO: Add Image Carousel
          _buildInfoRow(context, 'Название:', room.name),
          _buildInfoRow(context, 'Тип:', room.type.displayName),
          _buildInfoRow(context, 'Описание:', room.description ?? 'N/A'),
          _buildInfoRow(context, 'Вместимость:', '${room.maxCapacity} чел.'),
          if (room.buildingName?.isNotEmpty == true)
            _buildInfoRow(context, 'Корпус:', room.buildingName!),
          if (room.floor != null) // Changed from isNotEmpty
            _buildInfoRow(context, 'Этаж:', room.floor.toString()), // Changed to toString()
          if (room.roomNumber?.isNotEmpty == true)
            _buildInfoRow(context, 'Номер комнаты:', room.roomNumber!),
          _buildInfoRow(context, 'Площадь:', '${room.area ?? 'N/A'} м²'),
          const SizedBox(height: 16.0),
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(context, 'Статус:', room.isActive ? 'Активно' : 'Неактивно'),
                
                // Дата, Кто (from archive)
                if (room.archivedAt != null) ...[
                  _buildInfoRow(context, 'Архивировано:', DateFormat('dd.MM.yyyy HH:mm').format(room.archivedAt!.toLocal())),
                  if (room.archivedByName?.isNotEmpty == true)
                    _buildInfoRow(context, 'Кем архивировано:', room.archivedByName!),
                ],

                // Причина (from deactivation)
                if (!room.isActive && room.deactivateReason?.isNotEmpty == true)
                  _buildInfoRow(context, 'Причина деактивации:', room.deactivateReason!),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 220,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}
