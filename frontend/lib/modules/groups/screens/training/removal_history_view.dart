import 'package:fitman_app/modules/users/providers/users_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitman_common/fitman_common.dart';
import 'package:intl/intl.dart';
import '../../providers/group_providers.dart';

class RemovalHistoryView extends ConsumerWidget {
  final String groupId;

  const RemovalHistoryView({super.key, required this.groupId});

  String _roleLabel(String role) {
    switch (role) {
      case 'trainer':
        return 'Тренер';
      case 'instructor':
        return 'Инструктор';
      case 'manager':
        return 'Менеджер';
      case 'client':
        return 'Клиент';
      default:
        return role;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final removalsAsync = ref.watch(groupRemovalsProvider(groupId));
    final allUsers = ref.watch(usersProvider).users;

    String getUserName(String userId) {
      final user = allUsers.firstWhere(
        (u) => u.id == userId,
        orElse: () => User.fromJson({
          'id': userId,
          'first_name': 'Неизвестный',
          'last_name': 'Пользователь',
        }),
      );
      return user.fullName;
    }

    return removalsAsync.when(
      data: (removals) {
        if (removals.isEmpty) {
          return const Center(child: Text('История удалений пуста.'));
        }
        return ListView.builder(
          itemCount: removals.length,
          itemBuilder: (context, index) {
            final removal = removals[index];
            final userName = getUserName(removal.userId);
            final initiator = getUserName(removal.initiatorId);
            final roleLabel = _roleLabel(removal.userRole);

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                title: Text('Удаление: $userName ($roleLabel)'),
                subtitle: Text(
                  'Дата: ${DateFormat('dd.MM.yyyy HH:mm').format(removal.removedAt.toLocal())}\n'
                  'Причина: ${removal.reason}\n'
                  'Инициатор: $initiator',
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) =>
          Center(child: Text('Ошибка загрузки истории: $error')),
    );
  }
}
