import 'package:fitman_app/modules/supportStaff/models/support_staff.model.dart';
import 'package:fitman_app/modules/supportStaff/providers/support_staff_provider.dart';
import 'package:fitman_app/modules/supportStaff/screens/support_staff_detail_screen.dart';
import 'package:fitman_app/modules/supportStaff/screens/support_staff_edit_screen.dart';
import 'package:fitman_app/modules/users/providers/users_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SupportStaffListScreen extends ConsumerWidget {
  const SupportStaffListScreen({super.key});

  void _showArchiveDialog(
      BuildContext context, WidgetRef ref, SupportStaff staff) {
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
              title: Text('Архивировать "${staff.firstName} ${staff.lastName}"'),
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
                          ref.read(supportStaffNotifierProvider.notifier).archive(
                              staff.id, reasonController.text.trim());
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
    final showArchived = ref.watch(supportStaffFilterIncludeArchivedProvider);
    final staffListAsync = ref.watch(allSupportStaffProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Вспомогательный персонал'),
        actions: [
          Row(
            children: [
              const Text('Архив'),
              Switch(
                value: showArchived,
                onChanged: (value) {
                  ref
                      .read(supportStaffFilterIncludeArchivedProvider.notifier)
                      .state = value;
                },
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SupportStaffEditScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: staffListAsync.when(
        data: (staffList) {
          if (staffList.isEmpty) {
            return const Center(child: Text('Нет данных'));
          }
          return ListView.builder(
            itemCount: staffList.length,
            itemBuilder: (context, index) {
              final staff = staffList[index];
              final isArchived = staff.archivedAt != null;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                color: isArchived ? Colors.grey.shade200 : null,
                child: ListTile(
                  title: Text('${staff.lastName} ${staff.firstName}'),
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
                                staff.archivedAt
                                        ?.toLocal()
                                        .toString()
                                        .substring(0, 10) ??
                                    'N/A'),
                            ArchivedByInfo(userId: staff.archivedBy),
                            _buildInfoRow(context, 'Причина:',
                                staff.archivedReason ?? 'N/A'),
                          ],
                        )
                      : Text(staff.category.toString()),
                  onTap: () {
                    if (!isArchived) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              SupportStaffDetailScreen(staffId: staff.id),
                        ),
                      );
                    }
                  },
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'edit') {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SupportStaffEditScreen(staff: staff),
                          ),
                        );
                      } else if (value == 'archive') {
                        _showArchiveDialog(context, ref, staff);
                      } else if (value == 'unarchive') {
                        ref.read(supportStaffNotifierProvider.notifier).unarchive(staff.id);
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
            child: Text(value, style: Theme.of(context).textTheme.bodySmall)),
      ],
    ),
  );
}
