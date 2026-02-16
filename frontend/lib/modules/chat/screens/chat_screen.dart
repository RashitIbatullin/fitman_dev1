import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/chat_provider.dart'; // Adjusted relative path
import '../../../providers/auth_provider.dart'; // Adjusted relative path
import '../widgets/message_bubble.dart'; // Corrected path within the module
// Removed: import '../models/chat_models.dart'; // Import the Message model

class ChatScreen extends ConsumerStatefulWidget {
  final int chatId;
  final String chatTitle;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.chatTitle,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController(); // Add ScrollController

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatProvider.notifier).setActiveChat(widget.chatId);
      _sendReadStatusUpdates(); // Send read status after setting active chat and messages are loaded
      _scrollController.addListener(_onScroll);
      ref.listen<ChatState>(chatProvider, (prev, next) {
        if (next.activeChatId == widget.chatId && !next.isLoading && (prev?.isLoading ?? true)) {
          _sendReadStatusUpdates();
        }
      });
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
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
    final chatState = ref.watch(chatProvider);
    final currentUser = ref.watch(authProvider).value?.user;
    final messages = chatState.messages[widget.chatId] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatTitle),
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty && chatState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    reverse: true,
                    controller: _scrollController, // Assign scroll controller
                    itemCount: messages.length + (chatState.isFetchingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == messages.length && chatState.isFetchingMore) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final message = messages[index];
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
            padding: const EdgeInsets.all(8.0),
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
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
