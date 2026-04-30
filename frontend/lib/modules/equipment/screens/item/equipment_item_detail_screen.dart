import 'package:carousel_slider/carousel_slider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fitman_app/services/api_service.dart';
import 'package:fitman_app/modules/equipment/widgets/maintenance_list_tile.dart';
import 'package:fitman_common/fitman_common.dart';
import 'equipment_item_edit_screen.dart';
import 'package:fitman_app/modules/equipment/screens/item/equipment_maintenance_history_edit_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitman_app/extensions/equipment_ui_extensions.dart';
import 'package:fitman_app/modules/equipment/providers/equipment/equipment_provider.dart';
import 'package:fitman_app/modules/equipment/providers/maintenance_provider.dart';
import 'package:fitman_app/modules/rooms/providers/room/room_provider.dart';
import 'package:fitman_app/modules/users/providers/users_provider.dart';

class EquipmentItemDetailScreen extends ConsumerStatefulWidget {
  const EquipmentItemDetailScreen({super.key, required this.itemId});

  final String itemId;

  @override
  ConsumerState<EquipmentItemDetailScreen> createState() =>
      _EquipmentItemDetailScreenState();
}

class _EquipmentItemDetailScreenState
    extends ConsumerState<EquipmentItemDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 4,
        vsync:
            this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadPhoto(
      BuildContext context, WidgetRef ref, String equipmentId) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null && result.files.single.bytes != null) {
      final fileBytes = result.files.single.bytes!;
      final fileName = result.files.single.name;

      try {
        await ApiService.uploadEquipmentPhoto(
          equipmentId: equipmentId,
          photoBytes: fileBytes,
          fileName: fileName,
        );
        ref.invalidate(equipmentItemByIdProvider(equipmentId));
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Фото успешно загружено')),
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка загрузки фото: $e')),
        );
      }
    }
  }

  Future<bool?> _showDeleteConfirmationDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Удалить фото?'),
          content: const Text('Вы уверены, что хотите удалить это фото?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Удалить'),
            ),
          ],
        );
      },
    );
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
                      equipmentItem: item,
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
            Tab(text: 'Фото'),
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
              _buildPhotosTab(context, ref, item),
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
    final roomAsync =
        item.roomId != null ? ref.watch(roomByIdProvider(item.roomId!)) : null;

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
                  item.photoUrls.first.startsWith('http')
                      ? item.photoUrls.first
                      : '${ApiService.baseUrl}${item.photoUrls.first}',
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          _buildDetailRow(label: 'Инв. номер:', value: item.inventoryNumber),
          typeAsync.when(
            data: (type) => _buildDetailRow(label: 'Тип:', value: type.name),
            loading: () => _buildDetailRow(label: 'Тип:', value: 'Загрузка...'),
            error: (err, stack) =>
                _buildDetailRow(label: 'Тип:', value: 'Ошибка'),
          ),
          if (item.serialNumber != null && item.serialNumber!.isNotEmpty)
            _buildDetailRow(label: 'Сер. номер:', value: item.serialNumber!),
          if (item.model != null && item.model!.isNotEmpty)
            _buildDetailRow(label: 'Модель:', value: item.model!),
          if (item.manufacturer != null && item.manufacturer!.isNotEmpty)
            _buildDetailRow(
                label: 'Производитель:', value: item.manufacturer!),
          roomAsync != null
              ? roomAsync.when(
                  data: (room) =>
                      _buildDetailRow(label: 'Помещение:', value: room.name),
                  loading: () =>
                      _buildDetailRow(label: 'Помещение:', value: 'Загрузка...'),
                  error: (err, stack) =>
                      _buildDetailRow(label: 'Помещение:', value: 'Ошибка'),
                )
              : _buildDetailRow(label: 'Помещение:', value: 'Не назначено'),
          if (item.placementNote != null && item.placementNote!.isNotEmpty)
            _buildDetailRow(label: 'Расположение:', value: item.placementNote!),
          const Divider(height: 32),
          _buildDetailRow(
            label: 'Статус:',
            value: item.status.displayName,
            valueColor: item.status.color,
          ),
          _buildConditionRating(item.conditionRating),
          if (item.conditionNotes != null && item.conditionNotes!.isNotEmpty)
            _buildDetailRow(
                label: 'Заметки о состоянии:', value: item.conditionNotes!),
        ],
      ),
    );
  }

  Widget _buildPhotosTab(
      BuildContext context, WidgetRef ref, EquipmentItem item) {
    if (item.photoUrls.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Нет фотографий',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                print('Add photo button pressed!');
                _pickAndUploadPhoto(context, ref, item.id);
              },
              icon: const Icon(Icons.add_a_photo),
              label: const Text('Добавить фото'),
            ),
          ],
        ),
      );
    }
    final baseUrl = ApiService.baseUrl;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        children: [
          CarouselSlider.builder(
            itemCount: item.photoUrls.length,
            itemBuilder: (context, index, realIndex) {
              final photoUrl = item.photoUrls[index];
              final fullUrl = photoUrl.startsWith('http')
                  ? photoUrl
                  : '$baseUrl/${photoUrl.startsWith('/') ? photoUrl.substring(1) : photoUrl}';
              return Stack( 
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                      child: Image.network(
                        fullUrl,
                        fit: BoxFit.cover,
                        width: 1000,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.error, color: Colors.red, size: 48),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8.0,
                    right: 8.0,
                    child: GestureDetector(
                      onTap: () async {
                        final confirm = await _showDeleteConfirmationDialog(context);
                        if (confirm == true) {
                          try {
                            await ApiService.removeEquipmentPhoto(
                                equipmentId: item.id, photoUrl: photoUrl);
                            ref.invalidate(equipmentItemByIdProvider(item.id));
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Фото успешно удалено')),
                            );
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Ошибка удаления фото: $e')),
                            );
                          }
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          color: Colors.red.withAlpha((0.7 * 255).round()),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: const Icon(Icons.delete, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              );
            },
            options: CarouselOptions(
              height: 400.0,
              enlargeCenterPage: true,
              autoPlay: item.photoUrls.length > 1,
              aspectRatio: 16 / 9,
              autoPlayCurve: Curves.fastOutSlowIn,
              enableInfiniteScroll: item.photoUrls.length > 1,
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
              viewportFraction: 0.8,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              print('Add photo button pressed!');
              _pickAndUploadPhoto(context, ref, item.id);
            },
            icon: const Icon(Icons.add_a_photo),
            label: const Text('Добавить фото'),
          ),
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

  void _showArchiveDialog(BuildContext context, WidgetRef ref, EquipmentMaintenanceHistory record) {
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            void validate() {
              setState(() {
                formKey.currentState?.validate();
              });
            }

            reasonController.addListener(validate);

            return AlertDialog(
              title: const Text('Архивировать запись'),
              content: Form(
                key: formKey,
                child: TextFormField(
                  controller: reasonController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Причина архивации',
                    hintText: 'Минимум 5 символов',
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null || value.trim().length < 5) {
                      return 'Причина должна быть не менее 5 символов.';
                    }
                    return null;
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    reasonController.removeListener(validate);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Отмена'),
                ),
                TextButton(
                  onPressed: formKey.currentState?.validate() ?? false
                      ? () {
                          ref.read(maintenanceProvider.notifier).archiveMaintenanceHistory(
                                record.id!,
                                record.equipmentItemId,
                                reasonController.text.trim(),
                              );
                          reasonController.removeListener(validate);
                          Navigator.of(context).pop();
                        }
                      : null,
                  child: const Text('Архивировать'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label ', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value, style: Theme.of(context).textTheme.bodySmall)),
        ],
      ),
    );
  }

  Widget _buildMaintenanceHistoryTab(String itemId) {
    final historyAsync = ref.watch(maintenanceHistoryProvider(itemId));
    final showArchived = ref.watch(maintenanceHistoryFilterIncludeArchivedProvider);

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text('Архив'),
                Switch(
                  value: showArchived,
                  onChanged: (value) {
                    ref.read(maintenanceHistoryFilterIncludeArchivedProvider.notifier).state = value;
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: historyAsync.when(
              data: (history) {
                if (history.isEmpty) {
                  return const Center(child: Text('Нет записей в истории обслуживания.'));
                }
                history.sort((a, b) {
                  if (a.createdAt == null && b.createdAt == null) return 0;
                  if (a.createdAt == null) return 1;
                  if (b.createdAt == null) return -1;
                  return b.createdAt!.compareTo(a.createdAt!);
                });

                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final record = history[index];
                    final isArchived = record.archivedAt != null;

                    return MaintenanceListTile(
                      historyItem: record,
                      statusDetails: isArchived
                          ? Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Архивировано', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown)),
                                  _buildInfoRow(context, 'Когда:', record.archivedAt?.toLocal().toString().substring(0, 10) ?? 'N/A'),
                                  ArchivedByInfo(userId: record.archivedBy, isSmall: true),
                                  _buildInfoRow(context, 'Причина:', record.archivedReason ?? 'N/A'),
                                ],
                              ),
                            )
                          : null,
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            Navigator.of(context).push<bool>(
                              MaterialPageRoute(
                                builder: (context) => EquipmentMaintenanceHistoryEditScreen(
                                  equipmentItemId: record.equipmentItemId,
                                  historyRecord: record,
                                ),
                              ),
                            );
                          } else if (value == 'archive') {
                            _showArchiveDialog(context, ref, record);
                          } else if (value == 'unarchive') {
                            ref.read(maintenanceProvider.notifier).unarchiveMaintenanceHistory(record.id!, record.equipmentItemId);
                          }
                        },
                        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                          if (!isArchived) ...[
                            const PopupMenuItem<String>(
                              value: 'edit',
                              child: Text('Редактировать'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'archive',
                              child: Text('Архивировать'),
                            ),
                          ] else ...[
                            const PopupMenuItem<String>(
                              value: 'unarchive',
                              child: Text('Деархивировать'),
                            ),
                          ]
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, st) => Center(child: Text('Ошибка: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EquipmentMaintenanceHistoryEditScreen(
                equipmentItemId: itemId,
              ),
            ),
          );
        },
        tooltip: 'Добавить запись',
        child: const Icon(Icons.add),
      ),
    );
  }
}

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
  const ArchivedByInfo({super.key, this.userId, this.isSmall = false});

  final String? userId;
  final bool isSmall;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (userId == null) {
      return _buildRow(context, 'Кто:', 'N/A');
    }

    final userAsync = ref.watch(userByIdProvider(userId!));

    return userAsync.when(
      data: (user) => _buildRow(context, 'Кто:', user.shortName),
      loading: () => _buildRow(context, 'Кто:', 'Загрузка...'),
      error: (err, stack) => _buildRow(context, 'Кто:', 'Ошибка'),
    );
  }

  Widget _buildRow(BuildContext context, String label, String value) {
    if (isSmall) {
        return Padding(
        padding: const EdgeInsets.symmetric(vertical: 1.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$label ', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
            Expanded(child: Text(value, style: Theme.of(context).textTheme.bodySmall)),
          ],
        ),
      );
    }
    return _buildDetailRow(label: label, value: value);
  }
}
