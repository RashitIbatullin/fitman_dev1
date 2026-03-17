import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitman_app/modules/supportStaff/models/competency.model.dart';
import 'package:fitman_app/modules/supportStaff/models/competency_level.enum.dart';
import 'package:fitman_app/modules/equipment/models/equipment_maintenance_history.model.dart';
import '../providers/competency_provider.dart';

class CompetencyTab extends ConsumerWidget {
  final String employeeId;

  const CompetencyTab({super.key, required this.employeeId});

  void _showAddCompetencyDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    CompetencyLevel? selectedLevel;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Добавить компетенцию'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Название компетенции'),
              ),
              DropdownButtonFormField<CompetencyLevel>(
                initialValue: selectedLevel,
                hint: const Text('Уровень'),
                onChanged: (level) {
                  selectedLevel = level;
                },
                items: CompetencyLevel.values
                    .map((level) => DropdownMenuItem(
                          value: level,
                          child: Text(level.toString().split('.').last),
                        ))
                    .toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Отмена'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Добавить'),
              onPressed: () {
                if (nameController.text.isNotEmpty && selectedLevel != null) {
                  final newCompetency = Competency(
                    id: '', // ID is assigned by the backend
                    competentId: employeeId,
                    executorType: ExecutorType.user,
                    name: nameController.text,
                    level: selectedLevel!,
                  );
                  ref
                      .read(employeeCompetenciesProvider(employeeId).notifier)
                      .addCompetency(newCompetency);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final competenciesAsync = ref.watch(employeeCompetenciesProvider(employeeId));

    return Scaffold(
      body: competenciesAsync.when(
        data: (competencies) {
          if (competencies.isEmpty) {
            return const Center(child: Text('Компетенции не найдены.'));
          }
          return ListView.builder(
            itemCount: competencies.length,
            itemBuilder: (context, index) {
              final competency = competencies[index];
              return ListTile(
                title: Text(competency.name),
                subtitle: Text('Уровень: ${competency.level.toString().split('.').last}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    ref
                        .read(employeeCompetenciesProvider(employeeId).notifier)
                        .deleteCompetency(competency.id);
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Ошибка: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCompetencyDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}
