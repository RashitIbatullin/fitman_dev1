import 'package:fitman_app/modules/equipment/providers/repair_time_standard_provider.dart';
import 'package:fitman_app/modules/equipment/screens/standards/repair_time_standard_edit_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RepairTimeStandardsScreen extends ConsumerWidget {
  const RepairTimeStandardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final standardsAsync = ref.watch(allRepairTimeStandardsProvider);
    final showArchived = ref.watch(repairTimeStandardFilterIncludeArchivedProvider);

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
                  ref.read(repairTimeStandardFilterIncludeArchivedProvider.notifier).state = value;
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
          return ListView.builder(
            itemCount: standards.length,
            itemBuilder: (context, index) {
              final standard = standards[index];
              return ListTile(
                title: Text(standard.name),
                subtitle: Text('Продолжительность: ${standard.standardDurationHours} ч.'),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => RepairTimeStandardEditScreen(standard: standard),
                        ),
                      );
                    } else if (value == 'archive') {
                      ref.read(repairTimeStandardNotifierProvider.notifier).archiveStandard(standard.id!, 'Archived from app');
                    } else if (value == 'unarchive') {
                      ref.read(repairTimeStandardNotifierProvider.notifier).unarchiveStandard(standard.id!);
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: Text('Редактировать'),
                    ),
                    if (standard.archivedAt == null)
                      const PopupMenuItem<String>(
                        value: 'archive',
                        child: Text('Архивировать'),
                      )
                    else
                      const PopupMenuItem<String>(
                        value: 'unarchive',
                        child: Text('Разархивировать'),
                      ),
                  ],
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => RepairTimeStandardEditScreen(standard: standard),
                    ),
                  );
                },
              );
            },
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
