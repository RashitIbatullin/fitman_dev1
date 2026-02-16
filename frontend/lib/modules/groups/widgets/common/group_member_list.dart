import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/group_providers.dart';
import '../../../../modules/users/models/user.dart';
import '../../../../modules/users/providers/users_provider.dart';

class GroupMemberList extends ConsumerWidget {
  final int groupId;
  const GroupMemberList({super.key, required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupMembersAsync = ref.watch(groupMembersProvider(groupId));
    final allUsersState = ref.watch(usersProvider); // This is a UsersState object

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        groupMembersAsync.when(
          data: (memberIds) {
            if (memberIds.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text('В этой группе пока нет участников.'),
              );
            }
            
            if (allUsersState.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (allUsersState.error != null) {
              return Text('Ошибка загрузки пользователей: ${allUsersState.error}');
            }

            final members = allUsersState.users.where((user) => memberIds.contains(user.id)).toList();
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: members.length,
              itemBuilder: (context, index) {
                final member = members[index];
                return ListTile(
                  title: Text(member.fullName),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                    onPressed: () {
                      ref.read(groupMembersProvider(groupId).notifier).removeMember(groupId, member.id);
                    },
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Text('Ошибка загрузки участников группы: $e'),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Добавить участника'),
            onPressed: () => _showAddMemberDialog(context, ref, allUsersState.users, groupMembersAsync.value ?? []),
          ),
        ),
      ],
    );
  }

  void _showAddMemberDialog(BuildContext context, WidgetRef ref, List<User> allUsers, List<int> currentMemberIds) {
    // 1. Filter for clients and exclude current members
    final availableClients = allUsers.where((user) {
      return user.roles.any((role) => role.name == 'client') && !currentMemberIds.contains(user.id);
    }).toList();

    showDialog(
      context: context,
      builder: (context) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            // 2. Filter clients based on the search query
            final filteredClients = availableClients.where((user) {
              final query = searchQuery.toLowerCase();
              return user.fullName.toLowerCase().contains(query) ||
                     (user.phone?.contains(query) ?? false);
            }).toList();

            return AlertDialog(
              title: const Text('Добавить клиента'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 3. Add search field
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Поиск по ФИО или телефону',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 4. Display the filtered list
                    Expanded(
                      child: filteredClients.isEmpty
                          ? const Text('Клиенты не найдены.')
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: filteredClients.length,
                              itemBuilder: (context, index) {
                                final user = filteredClients[index];
                                return ListTile(
                                  title: Text(user.fullName),
                                  subtitle: Text(user.phone ?? 'Нет телефона'),
                                  onTap: () {
                                    ref.read(groupMembersProvider(groupId).notifier).addMember(groupId, user.id);
                                    Navigator.of(context).pop();
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Отмена'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}