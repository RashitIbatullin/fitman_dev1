import 'package:fitman_app/modules/users/providers/users_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitman_app/modules/maintenance/models/equipment_maintenance_history.model.dart';
import 'package:fitman_app/modules/maintenance/providers/maintenance_provider.dart';
import 'package:fitman_app/modules/equipment/screens/item/equipment_maintenance_history_edit_screen.dart';

class MaintenanceDashboardScreen extends ConsumerWidget {
  const MaintenanceDashboardScreen({super.key});

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(allMaintenanceHistoryProvider);
    final showArchived = ref.watch(maintenanceFilterIncludeArchivedProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Журнал ТО'),
        actions: [
          Row(
            children: [
              const Text('Архив'),
              Switch(
                value: showArchived,
                onChanged: (value) {
                  ref.read(maintenanceFilterIncludeArchivedProvider.notifier).state = value;
                },
              ),
            ],
          ),
        ],
      ),
      body: historyAsync.when(
        data: (history) {
          if (history.isEmpty) {
            return const Center(child: Text('Нет записей в истории обслуживания.'));
          }
          final filteredHistory = showArchived
              ? history
              : history.where((r) => r.archivedAt == null).toList();

          if (filteredHistory.isEmpty) {
            return const Center(child: Text('Нет активных записей.'));
          }

          return ListView.builder(
            itemCount: filteredHistory.length,
            itemBuilder: (context, index) {
              final record = filteredHistory[index];
              final isArchived = record.archivedAt != null;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                color: isArchived ? Colors.grey.shade200 : null,
                child: ListTile(
                  title: Text(record.reportedProblem),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Оборудование: ${record.equipmentName ?? record.equipmentItemId}'),
                      Text('Статус: ${record.status.title}'),
                      if (isArchived)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                             const Text('Архивировано', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown)),
                             _buildInfoRow(context, 'Когда:', record.archivedAt?.toLocal().toString().substring(0, 10) ?? 'N/A'),
                              ArchivedByInfo(userId: record.archivedBy),
                             _buildInfoRow(context, 'Причина:', record.archivedReason ?? 'N/A'),
                          ],),
                        )
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.black),
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
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Ошибка: $err')),
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

final maintenanceFilterIncludeArchivedProvider = StateProvider<bool>((ref) => false);
