import 'package:fitman_app/modules/clients/providers/work_schedule_provider.dart';
import 'package:fitman_app/modules/equipment/screens/item/equipment_item_detail_screen.dart';
import 'package:fitman_app/modules/equipment/screens/item/equipment_item_edit_screen.dart';
import 'package:fitman_app/modules/equipment/providers/equipment/equipment_provider.dart';
import 'package:fitman_app/modules/rooms/room_type_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitman_app/modules/rooms/providers/room/room_provider.dart';
import 'package:intl/intl.dart'; // Added for DateFormat
import 'package:fitman_common/fitman_common.dart';
import 'package:fitman_app/extensions/equipment_ui_extensions.dart';
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
      length: 4, // Number of tabs
      child: Column(
        children: [
          const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Основное'),
              Tab(text: 'Расписание'),
              Tab(text: 'Оборудование'),
              Tab(text: 'Статистика'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                // 1. Основное
                _buildMainInfoTab(context, room),
                // 2. Расписание (Implemented)
                _buildScheduleTab(context, ref, room),
                // 3. Оборудование (Implemented)
                _buildEquipmentTab(context, ref, room.id),
                // 4. Статистика (Placeholder)
                const Center(child: Text('Информация о статистике')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getWeekdayName(int day) {
    switch (day) {
      case 1:
        return 'Понедельник';
      case 2:
        return 'Вторник';
      case 3:
        return 'Среда';
      case 4:
        return 'Четверг';
      case 5:
        return 'Пятница';
      case 6:
        return 'Суббота';
      case 7:
        return 'Воскресенье';
      default:
        return '';
    }
  }

  Widget _buildScheduleTab(BuildContext context, WidgetRef ref, Room room) {
    // Use default center schedule
    final defaultScheduleAsync = ref.watch(workScheduleProvider);
    return defaultScheduleAsync.when(
      data: (schedules) {
        // Sort schedules by day of the week to ensure correct order
        schedules.sort((a, b) => a.dayOfWeek.compareTo(b.dayOfWeek));
        return ListView.builder(
          itemCount: schedules.length,
          itemBuilder: (context, index) {
            final schedule = schedules[index];
            return ListTile(
              title: Text(_getWeekdayName(schedule.dayOfWeek)),
              trailing: Text(
                schedule.isDayOff
                    ? 'Выходной'
                    : '${schedule.startTime} - ${schedule.endTime}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: schedule.isDayOff ? Colors.red : Colors.green,
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) =>
          Center(child: Text('Ошибка загрузки расписания: $err')),
    );
  }

  void _showArchiveDialog(
      BuildContext context, WidgetRef ref, EquipmentItem item) {
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Архивировать оборудование'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: reasonController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Причина архивации',
                hintText: 'Укажите причину',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Причина не может быть пустой.';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  ref.read(equipmentProvider.notifier).archiveItem(
                        item.id,
                        reasonController.text.trim(),
                      );
                  Navigator.of(context).pop();
                  // Invalidate provider to refresh the list
                  ref.invalidate(equipmentInRoomProvider(roomId));
                }
              },
              child: const Text('Архивировать'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEquipmentTab(
      BuildContext context, WidgetRef ref, String roomId) {
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
                leading: Icon(item.status.icon, color: item.status.color),
                title: Text(item.model ?? 'Оборудование без модели'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Инв. №: ${item.inventoryNumber}'),
                    if (item.manufacturer != null)
                      Text('Производитель: ${item.manufacturer}'),
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EquipmentItemEditScreen(itemId: item.id, equipmentItem: item),
                        ),
                      );
                    } else if (value == 'archive') {
                      _showArchiveDialog(context, ref, item);
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: ListTile(
                        leading: Icon(Icons.edit_outlined),
                        title: Text('Редактировать'),
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'archive',
                      child: ListTile(
                        leading: Icon(Icons.archive_outlined),
                        title: Text('Архивировать'),
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          EquipmentItemDetailScreen(itemId: item.id),
                    ),
                  );
                },
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
