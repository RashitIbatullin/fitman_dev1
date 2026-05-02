import 'package:fitman_app/modules/equipment/providers/equipment/equipment_provider.dart';
import 'package:fitman_app/modules/equipment/providers/repair_time_standard_provider.dart';
import 'package:fitman_app/modules/equipment/screens/standards/repair_time_standard_edit_screen.dart';
import 'package:fitman_common/modules/equipment/repair_time_standard.model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitman_app/modules/users/providers/users_provider.dart';

class RepairTimeStandardsScreen extends ConsumerWidget {
  const RepairTimeStandardsScreen({super.key});

  void _showArchiveDialog(
      BuildContext context, WidgetRef ref, RepairTimeStandard standard) {
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
              title: Text('Архивировать "${standard.name}"'),
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
                              .read(repairTimeStandardNotifierProvider.notifier)
                              .archiveStandard(
                                  standard.id!, reasonController.text.trim());
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
    final standardsAsync = ref.watch(allRepairTimeStandardsProvider);
    final equipmentTypesAsync = ref.watch(allEquipmentTypesIncludingArchivedProvider);
    final showArchived =
        ref.watch(repairTimeStandardFilterIncludeArchivedProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Нормативы времени ремонта'),
        actions: [
          Row(
            children: [
              const Text('Архив'),
              Switch(
                value: showArchived,
                onChanged: (value) {
                  ref
                      .read(repairTimeStandardFilterIncludeArchivedProvider
                          .notifier)
                      .state = value;
                },
              ),
            ],
          )
        ],
      ),
      body: standardsAsync.when(
        data: (standards) {
          if (standards.isEmpty) {
            return const Center(child: Text('Нормативы не найдены.'));
          }

          return equipmentTypesAsync.when(
            data: (types) {
              final typeIdToNameMap = {for (var type in types) type.id: type.name};

              return ListView.builder(
                itemCount: standards.length,
                itemBuilder: (context, index) {
                  final standard = standards[index];
                  final typeName =
                      typeIdToNameMap[standard.equipmentTypeId] ?? 'Неизвестный тип';
                  final isArchived = standard.archivedAt != null;

                  return ListTile(
                    title: Text(
                      standard.name,
                      style: TextStyle(
                          fontSize: (Theme.of(context).textTheme.titleMedium?.fontSize ?? 16) - 2),
                    ),
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
                                  standard.archivedAt
                                          ?.toLocal()
                                          .toString()
                                          .substring(0, 10) ??
                                      'N/A'),
                              ArchivedByInfo(userId: standard.archivedBy),
                              _buildInfoRow(context, 'Причина:',
                                  standard.archivedReason ?? 'N/A'),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                typeName,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                    fontSize:
                                        (Theme.of(context).textTheme.bodyMedium?.fontSize ?? 14) - 2),
                              ),
                              Text(
                                'Продолжительность: ${standard.standardDurationHours} ч.',
                                style: TextStyle(
                                    fontSize:
                                        (Theme.of(context).textTheme.bodyMedium?.fontSize ?? 14) - 1),
                              ),
                            ],
                          ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  RepairTimeStandardEditScreen(standard: standard),
                            ),
                          );
                        } else if (value == 'archive') {
                          _showArchiveDialog(context, ref, standard);
                        } else if (value == 'unarchive') {
                          ref
                              .read(repairTimeStandardNotifierProvider.notifier)
                              .unarchiveStandard(standard.id!);
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        if (isArchived) {
                          return [
                            const PopupMenuItem<String>(
                              value: 'unarchive',
                              child: Text('Деархивировать'),
                            ),
                          ];
                        } else {
                          return [
                            const PopupMenuItem<String>(
                              value: 'edit',
                              child: Text('Редактировать'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'archive',
                              child: Text('Архивировать'),
                            ),
                          ];
                        }
                      },
                    ),
                    onTap: () {
                      if (!isArchived) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                RepairTimeStandardEditScreen(standard: standard),
                          ),
                        );
                      }
                    },
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Ошибка типов: $err')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Ошибка: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const RepairTimeStandardEditScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
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
            child: Text(value, style: Theme.of(context).textTheme.bodySmall)),
      ],
    ),
  );
}
