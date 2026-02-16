import 'package:fitman_app/modules/users/models/user.dart';
import 'package:fitman_app/screens/client_dashboard.dart';
import 'package:fitman_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../modules/chat/providers/chat_provider.dart'; // Adjusted relative path
import '../../../modules/chat/screens/chat_screen.dart'; // Adjusted relative path

// Провайдер для получения всех клиентов, назначенных инструктору
final assignedClientsProvider = FutureProvider.family<List<User>, int>((
  ref,
  instructorId,
) async {
  return ApiService.getAssignedClientsForInstructor(instructorId);
});

class ClientsView extends ConsumerWidget {
  final int instructorId;
  const ClientsView({super.key, required this.instructorId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientsAsyncValue = ref.watch(assignedClientsProvider(instructorId));

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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ClientDashboard(client: client, showBackButton: true),
                  ),
                );
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