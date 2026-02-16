import 'package:fitman_app/modules/users/models/user.dart';
import 'package:fitman_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';
import '../../../modules/chat/providers/chat_provider.dart'; // Adjusted relative path
import '../../../modules/chat/screens/chat_screen.dart'; // Adjusted relative path

// Провайдер для получения клиентов для конкретного менеджера
final assignedClientsProvider = FutureProvider.family<List<User>, int>((
  ref,
  managerId,
) async {
  final user = ref.watch(authProvider).value?.user;
  // We can only get clients if we are an admin.
  if (user?.roles.any((role) => role.name == 'admin') ?? false) {
    return ApiService.getAssignedClients(managerId);
  }
  return [];
});

class ClientsView extends ConsumerWidget {
  final int managerId;
  const ClientsView({super.key, required this.managerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientsAsyncValue = ref.watch(assignedClientsProvider(managerId));

    return clientsAsyncValue.when(
      data: (clients) {
        if (clients.isEmpty) {
          return const Center(child: Text('Нет назначенных клиентов.'));
        }
        return ListView.builder(
          itemCount: clients.length,
          itemBuilder: (context, index) {
            final client = clients[index];
            return ListTile(
              leading: const Icon(Icons.person),
              title: Text(client.fullName),
              subtitle: Text(client.email),
              trailing: IconButton(
                icon: const Icon(Icons.chat),
                onPressed: () async {
                  final chatNotifier = ref.read(chatProvider.notifier);
                  await chatNotifier.connect();
                  final chatId = await chatNotifier.openPrivateChat(client.id);
                  
                  if (!context.mounted) return;
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        chatId: chatId,
                        chatTitle: client.fullName,
                      ),
                    ),
                  );
                },
              ),
              onTap: () {
                // TODO: Implement navigation to client details
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) =>
          Center(child: Text('Ошибка загрузки клиентов: $error')),
    );
  }
}