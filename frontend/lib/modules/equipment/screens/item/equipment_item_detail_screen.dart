import 'package:fitman_app/modules/equipment/models/equipment/equipment_item.model.dart';
import 'package:fitman_app/modules/equipment/screens/equipment/item/equipment_item_edit_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitman_app/modules/equipment/providers/equipment/equipment_provider.dart';
import 'package:fitman_app/modules/equipment/models/equipment/equipment_status.enum.dart';
import 'package:fitman_app/modules/rooms/providers/room/room_provider.dart';
import 'package:fitman_app/modules/users/providers/users_provider.dart'; 

class EquipmentItemDetailScreen extends ConsumerStatefulWidget {
  const EquipmentItemDetailScreen({super.key, required this.itemId});

  final String itemId;

  @override
  ConsumerState<EquipmentItemDetailScreen> createState() => _EquipmentItemDetailScreenState();
}

class _EquipmentItemDetailScreenState extends ConsumerState<EquipmentItemDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this); // 4 tabs: Main, Condition, Accounting, Maintenance History
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemAsync = ref.watch(equipmentItemByIdProvider(widget.itemId));

    return Scaffold(
      appBar: AppBar(
        title: itemAsync.when(
          data: (item) => Text(item.inventoryNumber),
          loading: () => const Text('Загрузка...'),
          error: (error, stack) => const Text('Ошибка'),
        ),
        actions: [
          itemAsync.when(
            data: (item) => IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EquipmentItemEditScreen(
                      itemId: item.id,
                      equipmentItem: item, // Pass item to pre-fill form
                    ),
                  ),
                );
              },
            ),
            loading: () => const SizedBox.shrink(),
            error: (error, stack) => const SizedBox.shrink(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Основное'),
            Tab(text: 'Состояние'),
            Tab(text: 'Учет'),
            Tab(text: 'История ТО'),
          ],
        ),
      ),
      body: itemAsync.when(
        data: (item) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildMainInfoTab(item),
              _buildConditionTab(item),
              _buildAccountingTab(item),
              _buildMaintenanceHistoryTab(item.id),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Ошибка: $error')),
      ),
    );
  }

  Widget _buildMainInfoTab(EquipmentItem item) {
    final typeAsync = ref.watch(equipmentTypeByIdProvider(item.typeId));
    final roomAsync = item.roomId != null ? ref.watch(roomByIdProvider(item.roomId!)) : null;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.photoUrls.isNotEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Image.network(
                  item.photoUrls.first, // Display first photo
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          _buildDetailRow(label: 'Инв. номер:', value: item.inventoryNumber),
          typeAsync.when(
            data: (type) => _buildDetailRow(label: 'Тип:', value: type.name),
            loading: () => _buildDetailRow(label: 'Тип:', value: 'Загрузка...'),
            error: (err, stack) => _buildDetailRow(label: 'Тип:', value: 'Ошибка'),
          ),
          if (item.serialNumber != null && item.serialNumber!.isNotEmpty)
            _buildDetailRow(label: 'Сер. номер:', value: item.serialNumber!),
          if (item.model != null && item.model!.isNotEmpty)
            _buildDetailRow(label: 'Модель:', value: item.model!),
          if (item.manufacturer != null && item.manufacturer!.isNotEmpty)
            _buildDetailRow(label: 'Производитель:', value: item.manufacturer!),
          roomAsync != null
              ? roomAsync.when(
                  data: (room) => _buildDetailRow(label: 'Помещение:', value: room.name),
                  loading: () => _buildDetailRow(label: 'Помещение:', value: 'Загрузка...'),
                  error: (err, stack) => _buildDetailRow(label: 'Помещение:', value: 'Ошибка'),
                )
              : _buildDetailRow(label: 'Помещение:', value: 'Не назначено'),
          if (item.placementNote != null && item.placementNote!.isNotEmpty)
            _buildDetailRow(label: 'Расположение:', value: item.placementNote!),
        ],
      ),
    );
  }

  Widget _buildConditionTab(EquipmentItem item) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow(
            label: 'Статус:',
            value: item.status.displayName,
            valueColor: item.status.color,
          ),
          _buildConditionRating(item.conditionRating),
          if (item.conditionNotes != null && item.conditionNotes!.isNotEmpty)
            _buildDetailRow(label: 'Заметки о состоянии:', value: item.conditionNotes!),
          if (item.lastMaintenanceDate != null)
            _buildDetailRow(
                label: 'Последнее ТО:',
                value: item.lastMaintenanceDate!.toLocal().toIso8601String().substring(0, 10)),
          if (item.nextMaintenanceDate != null)
            _buildDetailRow(
                label: 'След. ТО:',
                value: item.nextMaintenanceDate!.toLocal().toIso8601String().substring(0, 10)),
          if (item.maintenanceNotes != null && item.maintenanceNotes!.isNotEmpty)
            _buildDetailRow(label: 'Заметки о ТО:', value: item.maintenanceNotes!),
          if (item.archivedAt != null) ...[
            const Divider(),
            _buildDetailRow(
                label: 'Архивировано:',
                value: item.archivedAt!.toLocal().toIso8601String().substring(0, 10)),
            ArchivedByInfo(userId: item.archivedBy),
            if (item.archivedReason != null && item.archivedReason!.isNotEmpty)
              _buildDetailRow(label: 'Причина:', value: item.archivedReason!),
          ],
        ],
      ),
    );
  }

  Widget _buildAccountingTab(EquipmentItem item) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.purchaseDate != null)
            _buildDetailRow(
                label: 'Дата покупки:',
                value: item.purchaseDate!.toLocal().toIso8601String().substring(0, 10)),
          if (item.purchasePrice != null)
            _buildDetailRow(
                label: 'Цена покупки:', value: '${item.purchasePrice}'),
          if (item.supplier != null && item.supplier!.isNotEmpty)
            _buildDetailRow(label: 'Поставщик:', value: item.supplier!),
          if (item.warrantyMonths != null)
            _buildDetailRow(
                label: 'Гарантия (мес.):', value: '${item.warrantyMonths}'),
          _buildDetailRow(label: 'Часы использ.:', value: '${item.usageHours}'),
          if (item.lastUsedDate != null)
            _buildDetailRow(
                label: 'Последнее использ.:',
                value: item.lastUsedDate!.toLocal().toIso8601String().substring(0, 10)),
        ],
      ),
    );
  }

  Widget _buildMaintenanceHistoryTab(String itemId) {
    final historyAsync = ref.watch(maintenanceHistoryProvider(itemId));
    
    return historyAsync.when(
      data: (history) {
        if (history.isEmpty) {
          return const Center(child: Text('Нет записей в истории обслуживания.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: history.length,
          itemBuilder: (context, index) {
            final record = history[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                title: Text(record.descriptionOfWork),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Отправлено: ${record.dateSent.toLocal().toString().substring(0, 10)}'),
                    if (record.dateReturned != null)
                      Text('Возвращено: ${record.dateReturned!.toLocal().toString().substring(0, 10)}'),
                    if (record.performedBy != null)
                      Text('Выполнено: ${record.performedBy}'),
                    if (record.cost != null)
                      Text('Стоимость: ${record.cost} руб.'),
                  ],
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // TODO: Navigate to Maintenance History Detail Screen if needed
                  // For now, just show a dialog with full details
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Детали записи ТО'),
                      content: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Описание: ${record.descriptionOfWork}'),
                            Text('Отправлено: ${record.dateSent.toLocal().toString().substring(0, 10)}'),
                            if (record.dateReturned != null)
                              Text('Возвращено: ${record.dateReturned!.toLocal().toString().substring(0, 10)}'),
                            if (record.cost != null)
                              Text('Стоимость: ${record.cost} руб.'),
                            if (record.performedBy != null)
                              Text('Выполнено: ${record.performedBy}'),
                            if (record.photos != null && record.photos!.isNotEmpty) ...[
                              const Divider(),
                              Text('Фотографии:', style: Theme.of(context).textTheme.titleMedium),
                              ...record.photos!.map((photo) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Image.network(photo.url, height: 100, fit: BoxFit.cover),
                                    if (photo.note.isNotEmpty) Text('Примечание: ${photo.note}'),
                                  ],
                                ),
                              )),
                            ]
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Закрыть'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, st) => Center(child: Text('Ошибка: $err')),
    );
  }
}

// Helper function for building detail rows
Widget _buildDetailRow({
  required String label,
  required String value,
  Color? valueColor,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 150,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: valueColor,
            ),
          ),
        ),
      ],
    ),
  );
}

// Helper function for building condition rating stars
Widget _buildConditionRating(int rating) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      children: [
        const SizedBox(
          width: 150,
          child: Text(
            'Состояние:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        ...List.generate(5, (index) {
          return Icon(
            index < rating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 20,
          );
        }),
      ],
    ),
  );
}

class ArchivedByInfo extends ConsumerWidget {
  const ArchivedByInfo({super.key, this.userId});

  final String? userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (userId == null) {
      return _buildDetailRow(label: 'Кто:', value: 'N/A');
    }
    final userIdInt = int.tryParse(userId!);
    if (userIdInt == null) {
      return _buildDetailRow(label: 'Кто:', value: 'Invalid ID');
    }

    final userAsync = ref.watch(userByIdProvider(userIdInt));

    return userAsync.when(
      data: (user) => _buildDetailRow(label: 'Кто:', value: user.shortName),
      loading: () => _buildDetailRow(label: 'Кто:', value: 'Загрузка...'),
      error: (err, stack) => _buildDetailRow(label: 'Кто:', value: 'Ошибка'),
    );
  }
}
