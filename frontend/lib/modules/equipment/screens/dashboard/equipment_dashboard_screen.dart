import 'package:fitman_app/modules/users/providers/users_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitman_app/extensions/equipment_ui_extensions.dart';
// ... (rest of the imports)
import 'package:fitman_app/modules/equipment/providers/equipment/equipment_provider.dart';
import 'package:fitman_common/fitman_common.dart';
import '../item/equipment_item_detail_screen.dart';
import '../item/equipment_item_edit_screen.dart';
import 'package:fitman_app/modules/equipment/screens/standards/repair_time_standards_screen.dart';
import '../type/equipment_types_list_screen.dart';
import 'package:collection/collection.dart';


class EquipmentDashboardScreen extends ConsumerStatefulWidget {
  const EquipmentDashboardScreen({super.key});

  @override
  ConsumerState<EquipmentDashboardScreen> createState() =>
      _EquipmentDashboardScreenState();
}

class _EquipmentDashboardScreenState
    extends ConsumerState<EquipmentDashboardScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      ref
          .read(equipmentFilterSearchQueryProvider.notifier)
          .state = _searchController.text;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final equipmentItemsAsync = ref.watch(allEquipmentItemsProvider);
    final selectedStatus = ref.watch(equipmentFilterStatusProvider);
    final selectedRoomId = ref.watch(equipmentFilterRoomIdProvider);
    final selectedCondition = ref.watch(equipmentFilterConditionRatingProvider);
    final showArchived = ref.watch(equipmentItemFilterIncludeArchivedProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Управление оборудованием'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const EquipmentTypesListScreen()),
              );
            },
            child: const Text('Типы'),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const RepairTimeStandardsScreen()),
              );
            },
            child: const Text('Нормативы'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Поиск по инв. номеру, модели, производителю',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _searchController.clear(),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _TypePicker(),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: DropdownButtonFormField<EquipmentStatus>(
                        decoration: const InputDecoration(
                            labelText: 'Статус', border: OutlineInputBorder()),
                        initialValue: selectedStatus,
                        items: [
                          const DropdownMenuItem(
                              value: null, child: Text('Все')),
                          ...EquipmentStatus.values.map((status) =>
                              DropdownMenuItem(
                                value: status,
                                child: Row(
                                  children: [
                                    Icon(status.icon,
                                        size: 20, color: status.color),
                                    const SizedBox(width: 8.0),
                                    Text(status.displayName),
                                  ],
                                ),
                              )),
                        ],
                        onChanged: (value) => ref
                            .read(equipmentFilterStatusProvider.notifier)
                            .state = value,
                      ),
                    ),
                  ],
                ),
                 Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text('Архив'), // Renamed label
                    Switch(
                      value: showArchived,
                      onChanged: (value) {
                        ref.read(equipmentItemFilterIncludeArchivedProvider.notifier).state = value; // Use item-specific filter
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: equipmentItemsAsync.when(
              data: (items) {
                final selectedType = ref.watch(equipmentFilterEquipmentTypeProvider);
                final filteredItems = items.where((item) {
                  final searchQuery = ref.watch(equipmentFilterSearchQueryProvider);
                  final matchesSearch = searchQuery.isEmpty ||
                      item.inventoryNumber
                          .toLowerCase()
                          .contains(searchQuery.toLowerCase()) ||
                      (item.model
                              ?.toLowerCase()
                              .contains(searchQuery.toLowerCase()) ??
                          false) ||
                      (item.manufacturer
                              ?.toLowerCase()
                              .contains(searchQuery.toLowerCase()) ??
                          false);

                  final matchesType = selectedType == null || item.typeId == selectedType.id;
                  final matchesStatus = selectedStatus == null || item.status == selectedStatus;
                  final matchesRoom = selectedRoomId == null || item.roomId == selectedRoomId;
                  final matchesCondition = selectedCondition == null || item.conditionRating == selectedCondition;

                  return matchesSearch &&
                      matchesType &&
                      matchesStatus &&
                      matchesRoom &&
                      matchesCondition;
                }).toList();

                if (filteredItems.isEmpty) {
                  return const Center(
                      child: Text('Экземпляры оборудования не найдены.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80.0), // Add padding for FAB
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    return EquipmentItemCard(
                      item: item,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  EquipmentItemDetailScreen(itemId: item.id)),
                        );
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Ошибка: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const EquipmentItemEditScreen()),
          );
          ref.invalidate(allEquipmentItemsProvider);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _TypePicker extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typesAsync = ref.watch(allEquipmentTypesProvider);
    final selectedType = ref.watch(equipmentFilterEquipmentTypeProvider);

    return typesAsync.when(
      data: (types) {
        final grouped = groupBy(types, (EquipmentType type) => type.category);

        return OutlinedButton(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.all(16),
            side: BorderSide(color: Theme.of(context).colorScheme.outline),
          ),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (context) {
                return ListView(
                  children: [
                    ListTile(
                      title: const Text('Все типы', style: TextStyle(fontWeight: FontWeight.bold)),
                      onTap: () {
                        ref.read(equipmentFilterEquipmentTypeProvider.notifier).state = null;
                        Navigator.pop(context);
                      },
                    ),
                    ...grouped.entries.map((entry) {
                      return ExpansionTile(
                        leading: Icon(entry.key.icon, size: 24),
                        title: Text(entry.key.displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        children: entry.value.map((type) {
                          return ListTile(
                            title: Text(type.name),
                            onTap: () {
                              ref.read(equipmentFilterEquipmentTypeProvider.notifier).state = type;
                              Navigator.pop(context);
                            },
                          );
                        }).toList(),
                      );
                    }),
                  ],
                );
              },
            );
          },
          child: Text(selectedType?.name ?? 'Все типы'),
        );
      },
      loading: () => const OutlinedButton(onPressed: null, child: Text('Загрузка...')),
      error: (e, s) => OutlinedButton(onPressed: null, child: Text('Ошибка')),
    );
  }
}


class EquipmentItemCard extends ConsumerWidget {
  const EquipmentItemCard({
    super.key,
    required this.item,
    this.onTap,
  });

  final EquipmentItem item;
  final VoidCallback? onTap;

  void _showArchiveDialog(
      BuildContext context, WidgetRef ref, EquipmentItem item) {
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
              title: Text('Архивировать "${item.inventoryNumber}"'),
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
                          ref
                              .read(equipmentProvider.notifier)
                              .archiveItem(
                                  item.id, reasonController.text.trim());
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArchived = item.archivedAt != null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      color: isArchived ? Colors.grey.shade200 : null,
      child: ListTile(
        onTap: onTap,
        leading: SizedBox(
          width: 50,
          height: 50,
          child: item.photoUrls.isNotEmpty
              ? Image.network(
                  item.photoUrls.first,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image),
                )
              : const Icon(Icons.fitness_center),
        ),
        title: Text(
          item.inventoryNumber,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(context, 'Тип:', item.typeName ?? 'N/A'),
                  _buildInfoRow(
                    context,
                    'Модель/Производитель:',
                    '${item.model ?? 'N/A'}${item.manufacturer != null && item.manufacturer!.isNotEmpty ? ' (${item.manufacturer})' : ''}',
                  ),
                  _buildInfoRow(
                      context, 'Помещение:', item.roomName ?? 'Не назначено'),
                ],
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isArchived) ...[
                    const Text('Архивировано', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown)),
                    _buildInfoRow(context, 'Когда:',
                        item.archivedAt?.toLocal().toString().substring(0, 10) ?? 'N/A'),
                    ArchivedByInfo(userId: item.archivedBy),
                    _buildInfoRow(context, 'Причина:', item.archivedReason ?? 'N/A'),
                  ] else ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Row(
                        children: [
                          Text('Статус: ',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                          Flexible(
                            child: Chip(
                              label: Text(item.status.displayName),
                              backgroundColor: item.status.color,
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Row(
                        children: [
                          Text('Состояние: ',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                          ...List.generate(5, (index) {
                            return Icon(
                              index < item.conditionRating
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 16,
                            );
                          }),
                        ],
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) async {
            switch (value) {
              case 'edit':
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        EquipmentItemEditScreen(equipmentItem: item),
                  ),
                );
                ref.invalidate(allEquipmentItemsProvider);
                break;
              case 'archive':
                _showArchiveDialog(context, ref, item);
                break;
              case 'unarchive':
                ref.read(equipmentProvider.notifier).unarchiveItem(item.id);
                break;
              case 'maintenance':
                // TODO: Implement mark maintenance logic
                break;
              case 'book':
                // TODO: Implement booking logic
                break;
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            if (!isArchived) ...[
              const PopupMenuItem<String>(
                value: 'edit',
                child: Text('Изменить'),
              ),
              const PopupMenuItem<String>(
                value: 'maintenance',
                child: Text('Отметить ТО'),
              ),
              const PopupMenuItem<String>(
                value: 'book',
                child: Text('Бронировать'),
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
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label ',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          Expanded(
              child:
                  Text(value, style: Theme.of(context).textTheme.bodySmall)),
        ],
      ),
    );
  }
}

class ArchivedByInfo extends ConsumerWidget {
  const ArchivedByInfo({super.key, this.userId});

  final String? userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (userId == null) {
      return _buildInfoRow(context, 'Кто:', 'N/A');
    }

    final userAsync = ref.watch(userByIdProvider(userId!));

    return userAsync.when(
      data: (user) => _buildInfoRow(context, 'Кто:', user.shortName),
      loading: () => _buildInfoRow(context, 'Кто:', 'Загрузка...'),
      error: (err, stack) => _buildInfoRow(context, 'Кто:', 'Ошибка'),
    );
  }

    Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label ',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          Expanded(
              child:
                  Text(value, style: Theme.of(context).textTheme.bodySmall)),
        ],
      ),
    );
  }
}
