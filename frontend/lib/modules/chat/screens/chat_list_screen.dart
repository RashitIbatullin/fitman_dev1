import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_provider.dart'; // Corrected path within the module
import '../widgets/create_chat_dialog.dart'; // Corrected path within the module
import 'chat_screen.dart'; // Corrected path within the module

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(chatProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Чаты'),
      ),
      body: chatState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : chatState.chats.isEmpty
              ? const Center(child: Text('У вас пока нет чатов. Создайте новый!'))
              : ListView.builder(
                  itemCount: chatState.chats.length,
                  itemBuilder: (context, index) {
                    final chat = chatState.chats[index];
                    return ListTile(
                      title: Text(chat.name ?? 'Чат с ${chat.id}'), // TODO: Better name for P2P
                      subtitle: Text(chat.lastMessage ?? 'Нет сообщений'),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ChatScreen(chatId: chat.id, chatTitle: chat.name ?? 'Чат с ${chat.id}'),
                        ));
                      },
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'chat_list_fab',
        onPressed: () async {
          final newChatId = await showDialog<int>(
            context: context,
            builder: (context) => const CreateChatDialog(),
          );
          if (newChatId != null && context.mounted) {
            // After creating a chat, refresh the chat list and navigate to the new chat
            ref.read(chatProvider.notifier).fetchChats();
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ChatScreen(chatId: newChatId, chatTitle: 'Новый чат'), // TODO: Get actual chat name
            ));
          }
        },
        child: const Icon(Icons.add_comment),
      ),
    );
  }
}