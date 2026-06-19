import 'package:fitman_app/modules/users/providers/users_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitman_common/fitman_common.dart';
import 'package:intl/intl.dart';
import '../../providers/group_providers.dart';

class ReplacementHistoryView extends ConsumerWidget {
  final String groupId;

  const ReplacementHistoryView({super.key, required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final replacementsAsync = ref.watch(groupReplacementsProvider(groupId));
    final allUsers = ref.watch(usersProvider).users;

    String getUserName(String userId) {
      final user = allUsers.firstWhere(
        (u) => u.id == userId,
        orElse: () => User.fromJson({'id': userId, 'first_name': 'Неизвестный', 'last_name': 'Пользователь'}),
      );
      return user.fullName;
    }

    return replacementsAsync.when(
      data: (replacements) {
        if (replacements.isEmpty) {
          return const Center(child: Text('История замен и удалений пуста.'));
        }
        return ListView.builder(
          itemCount: replacements.length,
          itemBuilder: (context, index) {
            final replacement = replacements[index];
            final initiator = getUserName(replacement.initiatorId);
            
            String title = '';
            
            if (replacement.newEmployeeId != null) {
              final oldName = getUserName(replacement.oldEmployeeId ?? '');
              final newName = getUserName(replacement.newEmployeeId!);
              title = 'Замена: $oldName на $newName';
            } else {
              final oldName = getUserName(replacement.oldEmployeeId ?? '');
              title = 'Удаление: $oldName';
            }

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                title: Text(title),
                subtitle: Text(
                  'Дата: ${DateFormat('dd.MM.yyyy HH:mm').format(replacement.date.toLocal())}\n'
                  'Причина: ${replacement.reason}\n'
                  'Инициатор: $initiator',
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Ошибка загрузки истории: $error')),
    );
  }
}
