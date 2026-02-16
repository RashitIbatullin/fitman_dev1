import 'package:fitman_app/modules/users/models/user.dart';
import 'package:fitman_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../../modules/chat/providers/chat_provider.dart'; // Adjusted relative path
import '../../../providers/auth_provider.dart';
import '../../../modules/chat/widgets/message_bubble.dart'; // Adjusted relative path
// Removed: import '../../../modules/chat/screens/chat_screen.dart'; // Import ChatScreen

final trainerProvider = FutureProvider<User>((ref) async {
  return ApiService.getTrainerForClient();
});

class MyTrainerScreen extends ConsumerStatefulWidget {
  const MyTrainerScreen({super.key});

  @override
  ConsumerState<MyTrainerScreen> createState() => _MyTrainerScreenState();
}

class _MyTrainerScreenState extends ConsumerState<MyTrainerScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController(); // Add ScrollController
  
  @override
  void initState() {
    super.initState();
    _connectAndLoadChat();
    _scrollController.addListener(_onScroll); // Add scroll listener
  }

  Future<void> _connectAndLoadChat() async {
    final trainer = await ref.read(trainerProvider.future);
    final chatNotifier = ref.read(chatProvider.notifier);
    
    await chatNotifier.connect(); 
    await chatNotifier.openPrivateChat(trainer.id);

    // Initial read status update after chat is active
    _sendReadStatusUpdates();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.removeListener(_onScroll); // Remove scroll listener
    _scrollController.dispose(); // Dispose scroll controller
    ref.read(chatProvider.notifier).disconnect(); // Disconnect WebSocket
    super.dispose();
  }

  void _sendReadStatusUpdates() {
    final chatState = ref.read(chatProvider);
    final currentUser = ref.read(authProvider).value?.user;
    if (chatState.activeChatId == null) return;
    final messages = chatState.messages[chatState.activeChatId!] ?? [];

    for (final message in messages) {
      if (message.senderId != currentUser?.id) {
        ref.read(chatProvider.notifier).sendReadStatus(message.chatId, message.id);
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      ref.read(chatProvider.notifier).fetchMoreMessages().then((_) => _sendReadStatusUpdates());
    }
  }

  void _sendMessage({
    List<int>? fileBytes,
    String? fileName,
    String? mimeType,
  }) {
    final messageText = _messageController.text.trim();
    if (messageText.isNotEmpty || fileBytes != null) {
      ref.read(chatProvider.notifier).sendMessage(
        messageText,
        fileBytes: fileBytes,
        fileName: fileName,
        mimeType: mimeType,
      );
      _messageController.clear();
      // Scroll to bottom when new message is sent
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );

    if (result != null && result.files.single.bytes != null) {
      final platformFile = result.files.single;
      String? inferredMimeType;
      if (platformFile.extension != null) {
        switch (platformFile.extension!.toLowerCase()) {
          case 'jpg':
          case 'jpeg':
            inferredMimeType = 'image/jpeg';
            break;
          case 'png':
            inferredMimeType = 'image/png';
            break;
          case 'gif':
            inferredMimeType = 'image/gif';
            break;
          case 'pdf':
            inferredMimeType = 'application/pdf';
            break;
          case 'mp4':
            inferredMimeType = 'video/mp4';
            break;
          case 'mp3':
            inferredMimeType = 'audio/mpeg';
            break;
          default:
            inferredMimeType = 'application/octet-stream';
        }
      } else {
        inferredMimeType = 'application/octet-stream';
      }
      _sendMessage(
        fileBytes: platformFile.bytes,
        fileName: platformFile.name,
        mimeType: inferredMimeType,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final trainerData = ref.watch(trainerProvider);
    final chatState = ref.watch(chatProvider);
    final currentUser = ref.watch(authProvider).value?.user; // Get current user

    return trainerData.when(
      data: (trainer) {
        final currentChatMessages = chatState.activeChatId != null
            ? chatState.messages[chatState.activeChatId!] ?? []
            : [];

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    // backgroundImage: NetworkImage(trainer.photoUrl), // TODO: Add photo URL
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trainer.fullName,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        trainer.phone ?? '',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Чат с тренером',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        if (chatState.isLoading || chatState.isFetchingMore)
                          const LinearProgressIndicator(),
                        Expanded(
                          child: chatState.error != null
                              ? Center(child: Text('Ошибка чата: ${chatState.error}'))
                              : ListView.builder(
                                  reverse: true,
                                  controller: _scrollController, // Assign scroll controller
                                  itemCount: currentChatMessages.length + (chatState.isFetchingMore ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    if (index == currentChatMessages.length && chatState.isFetchingMore) {
                                      return const Center(child: CircularProgressIndicator());
                                    }
                                    final message = currentChatMessages[index];
                                    final isMe = message.senderId == currentUser?.id; 
                                    final userName = isMe 
                                        ? 'You' 
                                        : '${message.firstName ?? ''} ${message.lastName ?? ''}'.trim();
                                    return MessageBubble( // Use MessageBubble
                                      message: message,
                                      isMe: isMe,
                                      userName: userName,
                                    );
                                  },
                                ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.attach_file),
                                onPressed: _pickFile,
                              ),
                              Expanded(
                                child: TextField(
                                  controller: _messageController,
                                  decoration: InputDecoration(
                                    hintText: 'Введите сообщение...',
                                    suffixIcon: IconButton(
                                      icon: const Icon(Icons.send),
                                      onPressed: () => _sendMessage(),
                                    ),
                                  ),
                                  onSubmitted: (_) => _sendMessage(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Ошибка: $error')),
    );
  }
}