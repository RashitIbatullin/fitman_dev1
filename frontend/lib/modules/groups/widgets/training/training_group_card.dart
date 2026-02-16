import '../../models/training_group_type.model.dart';
import '../../../../modules/users/models/user.dart';
import '../../providers/group_providers.dart';
import '../../../../modules/users/providers/users_provider.dart';
import 'package:flutter/material.dart';
import '../../models/training_group.model.dart';
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

    Widget buildPersonnelInfo() {
      if (usersState.isLoading) {
        return _buildInfoRow(context, Icons.person, 'Тренер:', 'Загрузка...');
      }
      if (usersState.error != null) {
        return _buildInfoRow(context, Icons.person, 'Тренер:', 'Ошибка');
      }

      User? findUser(int? userId) {
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
          _buildInfoRow(context, Icons.person, 'Тренер:', trainer?.fullName ?? 'Неизвестно'),
          if (instructor != null)
            _buildInfoRow(context, Icons.person_outline, 'Инструктор:', instructor.fullName),
          if (manager != null)
            _buildInfoRow(context, Icons.manage_accounts, 'Менеджер:', manager.fullName),
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
          return _buildInfoRow(context, Icons.groups, 'Тип:', type?.title ?? 'Неизвестно');
        },
        loading: () => _buildInfoRow(context, Icons.groups, 'Тип:', 'Загрузка...'),
        error: (e, st) => _buildInfoRow(context, Icons.groups, 'Тип:', 'Ошибка'),
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
                        _buildInfoRow(context, Icons.calendar_today, 'Начало:', DateFormat('dd.MM.yyyy').format(group.startDate)),
                        if (group.endDate != null)
                          _buildInfoRow(context, Icons.calendar_today, 'Окончание:', DateFormat('dd.MM.yyyy').format(group.endDate!)),
                        _buildInfoRow(context, Icons.check_circle, 'Активна:', (group.isActive ?? false) ? 'Да' : 'Нет'),
                        _buildInfoRow(context, Icons.people, 'Участники:', '${group.currentParticipants ?? 0}/${group.maxParticipants}'),
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

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text('$label ', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value, style: Theme.of(context).textTheme.bodySmall)),
        ],
      ),
    );
  }
}