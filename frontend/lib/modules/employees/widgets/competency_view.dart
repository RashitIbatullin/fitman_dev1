import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitman_app/modules/supportStaff/models/competency_level.enum.dart';
import '../providers/competency_provider.dart';

class CompetencyView extends ConsumerWidget {
  final String employeeId;

  const CompetencyView({super.key, required this.employeeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final competenciesAsync = ref.watch(employeeCompetenciesProvider(employeeId));

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Компетенции ТО',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            competenciesAsync.when(
              data: (competencies) {
                if (competencies.isEmpty) {
                  return const Center(child: Text('Компетенции не назначены.'));
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: competencies.length,
                  itemBuilder: (context, index) {
                    final competency = competencies[index];
                    return ListTile(
                      title: Text(competency.name),
                      subtitle: Text('Уровень: ${competency.level.localizedName}'),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Ошибка загрузки компетенций: $err')),
            ),
          ],
        ),
      ),
    );
  }
}
