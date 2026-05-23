import 'package:fitman_common/modules/groups/training_group_type.model.dart';
import 'package:fitman_common/fitman_common.dart';
import '../../providers/group_providers.dart';
import '../../../../modules/users/providers/users_provider.dart';
import 'package:flutter/material.dart';
import 'package:fitman_common/modules/groups/training_group.model.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TrainingGroupCard extends ConsumerWidget {
  final TrainingGroup group;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const TrainingGroupCard({
    super.key,
    required this.group,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersState = ref.watch(usersProvider);
    final groupTypesAsync = ref.watch(trainingGroupTypesProvider);

    Widget buildCombinedRow(IconData icon, String text) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodySmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    Widget buildPersonnelInfo() {
      if (usersState.isLoading) {
        return buildCombinedRow(Icons.person, 'Тренер: Загрузка...');
      }
      if (usersState.error != null) {
        return buildCombinedRow(Icons.person, 'Тренер: Ошибка');
      }

      User? findUser(String? userId) {
        if (userId == null) return null;
        try {
          return usersState.users.firstWhere((user) => user.id == userId);
        } catch (e) {
          return null;
        }
      }

      final trainer = findUser(group.primaryTrainerId);
      final instructor = findUser(group.primaryInstructorId);
      final manager = findUser(group.responsibleManagerId);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildCombinedRow(Icons.person, 'Тренер: ${trainer?.fullName ?? 'Неизвестно'}'),
          if (instructor != null)
            buildCombinedRow(Icons.person_outline, 'Инструктор: ${instructor.fullName}'),
          if (manager != null)
            buildCombinedRow(Icons.manage_accounts, 'Менеджер: ${manager.fullName}'),
        ],
      );
    }
    
    Widget buildGroupTypeInfo() {
      return groupTypesAsync.when(
        data: (types) {
          TrainingGroupType? type;
          try {
            type = types.firstWhere((t) => t.id == group.trainingGroupTypeId);
          } catch (e) {
            type = null;
          }
          return buildCombinedRow(Icons.groups, 'Тип: ${type?.title ?? 'Неизвестно'}');
        },
        loading: () => buildCombinedRow(Icons.groups, 'Тип: Загрузка...'),
        error: (e, st) => buildCombinedRow(Icons.groups, 'Тип: Ошибка'),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      group.name,
                      style: Theme.of(context).textTheme.titleLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        onTap();
                      } else if (value == 'archive') {
                        onDelete();
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: Text('Редактировать'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'archive',
                        child: Text('Архивировать'),
                      ),
                    ],
                    icon: const Icon(Icons.more_vert),
                  ),
                ],
              ),
              if (group.description != null && group.description!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    group.description!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              const SizedBox(height: 12.0),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildPersonnelInfo(),
                        buildGroupTypeInfo(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildCombinedRow(Icons.calendar_today, 'Начало: ${DateFormat('dd.MM.yyyy').format(group.startDate)}'),
                        if (group.endDate != null)
                          buildCombinedRow(Icons.calendar_today, 'Окончание: ${DateFormat('dd.MM.yyyy').format(group.endDate!)}'),
                        buildCombinedRow(Icons.check_circle, 'Активна: ${(group.isActive ?? false) ? 'Да' : 'Нет'}'),
                        buildCombinedRow(Icons.people, 'Участники: ${group.currentParticipants ?? 0}/${group.maxParticipants}'),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
