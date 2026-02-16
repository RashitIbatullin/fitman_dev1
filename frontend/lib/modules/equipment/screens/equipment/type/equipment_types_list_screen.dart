import 'package:fitman_app/modules/users/providers/users_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitman_app/modules/equipment/providers/equipment/equipment_provider.dart';
import 'package:fitman_app/modules/equipment/models/equipment/equipment_type.model.dart';
import 'package:fitman_app/modules/equipment/models/equipment/equipment_category.enum.dart';
import 'package:fitman_app/modules/equipment/screens/equipment/type/equipment_type_detail_screen.dart';
import 'package:fitman_app/modules/equipment/screens/equipment/type/equipment_type_edit_screen.dart';

class EquipmentTypesListScreen extends ConsumerWidget {
  const EquipmentTypesListScreen({super.key});

  void _showArchiveDialog(
      BuildContext context, WidgetRef ref, EquipmentType equipmentType) {
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
              title: Text('Архивировать "${equipmentType.name}"'),
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
                              .archiveType(equipmentType.id, reasonController.text.trim());
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
    final equipmentTypesAsyncValue = ref.watch(allEquipmentTypesProvider);
    final showArchived = ref.watch(equipmentTypeFilterIncludeArchivedProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Типы оборудования'),
        actions: [
          Row(
            children: [
              const Text('Архив'), // Reverted label
              Switch(
                value: showArchived,
                onChanged: (value) {
                  ref
                      .read(equipmentTypeFilterIncludeArchivedProvider.notifier) // Use specific filter
                      .state = value;
                },
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
          PopupMenuButton<EquipmentCategory?>(
            onSelected: (category) {
              ref.read(equipmentFilterCategoryProvider.notifier).state =
                  category;
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                  value: null,
                  child: Text('Все категории'),
                ),
                ...EquipmentCategory.values.map((category) => PopupMenuItem(
                      value: category,
                      child: Text(category.displayName),
                    )),
              ];
            },
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  const EquipmentTypeEditScreen(), // For creating new
            ),
          );
          if (result == true) {
            ref.invalidate(allEquipmentTypesProvider);
          }
        },
        child: const Icon(Icons.add),
      ),
      body: equipmentTypesAsyncValue.when(
        data: (equipmentTypes) {
          if (equipmentTypes.isEmpty) {
            return const Center(
              child: Text('Нет типов оборудования'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 120.0), // Increased padding for FAB
            itemCount: equipmentTypes.length,
            itemBuilder: (context, index) {
              final equipmentType = equipmentTypes[index];
              final isArchived = equipmentType.archivedAt != null;

              return InkWell(
                onTap: () {
                  if (!isArchived) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EquipmentTypeDetailScreen(
                            equipmentTypeId: equipmentType.id),
                      ),
                    );
                  }
                },
                child: Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  color: isArchived ? Colors.grey.shade200 : null,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context)
                          .primaryColorLight, // Add a background color for visibility
                      child: Icon(
                        equipmentType.schematicIcon != null && equipmentType.schematicIcon!.isNotEmpty
                            ? _getSchematicIcon(equipmentType.schematicIcon!) // Use schematic icon
                            : equipmentType.category.icon, // Fallback to category icon
                        color: Theme.of(context)
                            .primaryColorDark, // Ensure icon color contrasts with background
                      ),
                    ),
                    title: Text(equipmentType.name),
                    subtitle: isArchived
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Архивировано',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.brown)),
                              _buildInfoRow(
                                  context,
                                  'Когда:',
                                  equipmentType.archivedAt
                                          ?.toLocal()
                                          .toString()
                                          .substring(0, 10) ??
                                      'N/A'),
                              ArchivedByInfo(userId: equipmentType.archivedBy),
                              _buildInfoRow(context, 'Причина:',
                                  equipmentType.archivedReason ?? 'N/A'),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'Категория: ${equipmentType.category.displayName}'),
                              if (equipmentType.weightRange != null &&
                                  equipmentType.weightRange!.isNotEmpty)
                                Text('Вес: ${equipmentType.weightRange}'),
                              if (equipmentType.dimensions != null &&
                                  equipmentType.dimensions!.isNotEmpty)
                                Text('Габариты: ${equipmentType.dimensions}'),
                            ],
                          ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'edit') {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EquipmentTypeEditScreen(
                                      equipmentTypeId: equipmentType.id),
                                ),
                              );
                              if (result == true) {
                                ref.invalidate(allEquipmentTypesProvider);
                              }
                            } else if (value == 'archive') {
                              _showArchiveDialog(context, ref, equipmentType);
                            } else if (value == 'unarchive') {
                              ref
                                  .read(equipmentProvider.notifier)
                                  .unarchiveType(equipmentType.id);
                            }
                          },
                          itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry<String>>[
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
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Ошибка: $error')),
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
    final userIdInt = int.tryParse(userId!);
    if (userIdInt == null) {
      return _buildInfoRow(context, 'Кто:', 'Invalid ID');
    }

    final userAsync = ref.watch(userByIdProvider(userIdInt));

    return userAsync.when(
      data: (user) => _buildInfoRow(context, 'Кто:', user.shortName),
      loading: () => _buildInfoRow(context, 'Кто:', 'Загрузка...'),
      error: (err, stack) => _buildInfoRow(context, 'Кто:', 'Ошибка'),
    );
  }
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

IconData _getSchematicIcon(String iconName) {
  // This is a placeholder. In a real app, you would have a map
  // or a way to dynamically resolve string names to actual IconData.
  // For example:
  switch (iconName) {
    case 'dumbbell':
      return Icons.fitness_center;
    case 'treadmill':
      return Icons.directions_run;
    case 'bike':
      return Icons.pedal_bike;
    case 'elliptical':
      return Icons.directions_walk;
    case 'barbell':
      return Icons.sports_gymnastics;
    case 'bench':
      return Icons.chair; // Placeholder
    case 'leg_press':
      return Icons.view_sidebar; // Placeholder
    case 'fitball':
      return Icons.sports_basketball; // Placeholder
    case 'yoga_mat':
      return Icons.spa; // Placeholder
    case 'scales':
      return Icons.scale;
    default:
      return Icons.category; // Default icon if not found
  }
}
