import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/chat_models.dart'; // Corrected path within the module
import '../../../services/api_service.dart'; // Adjusted relative path
import '../../../providers/auth_provider.dart'; // Adjusted relative path

@immutable
class ChatState {
  final List<Chat> chats;
  final Map<int, List<Message>> messages;
  final Map<int, MessagePaginationMetadata> messagesMetadata;
  final int? activeChatId;
  final bool isLoading;
  final bool isFetchingMore; // New field for loading more messages
  final String? error;
  final WebSocketChannel? webSocketChannel;

  const ChatState({
    this.chats = const [],
    this.messages = const {},
    this.messagesMetadata = const {},
    this.activeChatId,
    this.isLoading = false,
    this.isFetchingMore = false,
    this.error,
    this.webSocketChannel,
  });

  ChatState copyWith({
    List<Chat>? chats,
    Map<int, List<Message>>? messages,
    Map<int, MessagePaginationMetadata>? messagesMetadata, // Fixed type
    int? activeChatId,
    bool? isLoading,
    bool? isFetchingMore,
    String? error,
    WebSocketChannel? webSocketChannel,
    bool clearActiveChatId = false,
    bool clearWebSocketChannel = false, // Added for explicit clearing
  }) {
    return ChatState(
      chats: chats ?? this.chats,
      messages: messages ?? this.messages,
      messagesMetadata: messagesMetadata ?? this.messagesMetadata,
      activeChatId: clearActiveChatId ? null : activeChatId ?? this.activeChatId,
      isLoading: isLoading ?? this.isLoading,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      error: error ?? this.error,
      webSocketChannel: clearWebSocketChannel ? null : webSocketChannel ?? this.webSocketChannel,
    );
  }
}

@immutable
class MessagePaginationMetadata {
  final int offset;
  final int limit;
  final bool hasMore;

  const MessagePaginationMetadata({
    this.offset = 0,
    this.limit = 50,
    this.hasMore = true,
  });

  MessagePaginationMetadata copyWith({
    int? offset,
    int? limit,
    bool? hasMore,
  }) {
    return MessagePaginationMetadata(
      offset: offset ?? this.offset,
      limit: limit ?? this.limit,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class ChatNotifier extends Notifier<ChatState> {
  @override
  ChatState build() {
    ref.onDispose(() {
      state.webSocketChannel?.sink.close();
    });
    return const ChatState();
  }

  Future<void> connect() async {
    if (state.webSocketChannel != null && state.webSocketChannel!.closeCode == null) return;

    final token = ApiService.currentToken; // Changed to ApiService.currentToken
    if (token == null) {
      state = state.copyWith(error: 'Not authenticated', isLoading: false); // Added isLoading
      return;
    }
    
    final wsUrl = Uri.parse('${ApiService.baseUrl.replaceFirst('http', 'ws')}/api/chat/ws?token=$token');
    
    try {
      final channel = WebSocketChannel.connect(wsUrl);
      state = state.copyWith(webSocketChannel: channel, isLoading: false, error: null); // Added isLoading, error
      
      channel.stream.listen(
        (data) {
          final decodedData = jsonDecode(data);
          final type = decodedData['type'] as String?;

          switch (type) {
            case 'new_message':
              _addMessage(Message.fromJson(decodedData));
              break;
            case 'status_update':
              // TODO: Handle status updates on frontend
              print('Received status update: $decodedData');
              break;
            default:
              print('Received unknown message type: $decodedData');
          }
        },
        onError: (error) => state = state.copyWith(error: error.toString(), clearWebSocketChannel: true, isLoading: false), // clearWebSocketChannel
        onDone: () => state = state.copyWith(clearWebSocketChannel: true, isLoading: false), // clearWebSocketChannel
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false); // Added isLoading
    }
  }

  void disconnect() {
    state.webSocketChannel?.sink.close();
    state = state.copyWith(clearWebSocketChannel: true); // Using clearWebSocketChannel
  }

  Future<void> fetchChats() async {
    try {
      state = state.copyWith(isLoading: true);
      final chats = await ApiService.getChats();
      state = state.copyWith(chats: chats, isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> setActiveChat(int chatId) async {
    if (state.activeChatId == chatId && state.messages.containsKey(chatId)) {
      // If already active and messages loaded, no need to refetch
      return;
    }
    
    state = state.copyWith(activeChatId: chatId, isLoading: true, error: null);
    try {
      // Reset pagination metadata for the new active chat
      final newMetadata = Map<int, MessagePaginationMetadata>.from(state.messagesMetadata);
      newMetadata[chatId] = const MessagePaginationMetadata();

      final messages = await ApiService.getMessages(chatId, limit: newMetadata[chatId]!.limit, offset: 0);
      
      final currentMessages = Map<int, List<Message>>.from(state.messages);
      currentMessages[chatId] = messages;

      newMetadata[chatId] = newMetadata[chatId]!.copyWith(
        offset: messages.length,
        hasMore: messages.length == newMetadata[chatId]!.limit,
      );

      state = state.copyWith(messages: currentMessages, messagesMetadata: newMetadata, isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> fetchMoreMessages() async {
    if (state.activeChatId == null || state.isFetchingMore) return;

    final chatId = state.activeChatId!;
    final metadata = state.messagesMetadata[chatId] ?? const MessagePaginationMetadata();

    if (!metadata.hasMore) return;

    state = state.copyWith(isFetchingMore: true);

    try {
      final newMessages = await ApiService.getMessages(
        chatId,
        limit: metadata.limit,
        offset: metadata.offset,
      );

      final currentMessages = Map<int, List<Message>>.from(state.messages);
      final chatMessages = List<Message>.from(currentMessages[chatId] ?? []);
      chatMessages.addAll(newMessages); // Add new messages to the end (bottom of scroll)
      currentMessages[chatId] = chatMessages;

      final newMetadata = Map<int, MessagePaginationMetadata>.from(state.messagesMetadata);
      newMetadata[chatId] = metadata.copyWith(
        offset: metadata.offset + newMessages.length,
        hasMore: newMessages.length == metadata.limit,
      );

      state = state.copyWith(
        messages: currentMessages,
        messagesMetadata: newMetadata,
        isFetchingMore: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isFetchingMore: false);
    }
  }
  
  Future<int> openPrivateChat(int peerId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final chatId = await ApiService.createOrGetPrivateChat(peerId);
      await setActiveChat(chatId);
      return chatId;
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      rethrow;
    }
  }

  void sendMessage(String content, {List<int>? fileBytes, String? fileName, String? mimeType}) async {
    if (state.activeChatId == null || state.webSocketChannel == null) return;
    
    String? attachmentUrl;
    String? attachmentType;

    if (fileBytes != null && fileName != null) {
      try {
        final uploadResult = await ApiService.uploadChatAttachment(
          chatId: state.activeChatId!,
          fileBytes: fileBytes,
          fileName: fileName,
        );
        attachmentUrl = uploadResult.attachmentUrl;
        attachmentType = uploadResult.attachmentType;
      } catch (e) {
        state = state.copyWith(error: e.toString(), isLoading: false);
        return;
      }
    }

    final message = {
      'chat_id': state.activeChatId,
      'content': content,
      'attachment_url': attachmentUrl,
      'attachment_type': attachmentType,
    };

    state.webSocketChannel!.sink.add(jsonEncode(message));
  }
  
  void _addMessage(Message message) {
    final currentMessages = Map<int, List<Message>>.from(state.messages);
    final chatMessages = List<Message>.from(currentMessages[message.chatId] ?? []);
    
    if (!chatMessages.any((m) => m.id == message.id)) {
        chatMessages.insert(0, message); // New messages appear at the top
        currentMessages[message.chatId] = chatMessages;
        
        final newMetadata = Map<int, MessagePaginationMetadata>.from(state.messagesMetadata);
        newMetadata[message.chatId] = newMetadata[message.chatId]!.copyWith(
          offset: newMetadata[message.chatId]!.offset + 1, // Increment offset for new message
        );

        state = state.copyWith(messages: currentMessages, messagesMetadata: newMetadata);

        // Send 'delivered' status for the message if it's not from current user
        final currentUser = ref.read(authProvider).value?.user;
        if (message.senderId != currentUser?.id) {
          sendDeliveredStatus(message.chatId, message.id);
        }
    }
  }

  void sendDeliveredStatus(int chatId, int messageId) {
    if (state.webSocketChannel == null) return;
    final statusUpdate = {
      'type': 'status_update',
      'chat_id': chatId,
      'message_id': messageId,
      'status': 'delivered',
    };
    state.webSocketChannel!.sink.add(jsonEncode(statusUpdate));
  }

  void sendReadStatus(int chatId, int messageId) {
    if (state.webSocketChannel == null) return;
    final statusUpdate = {
      'type': 'status_update',
      'chat_id': chatId,
      'message_id': messageId,
      'status': 'read',
    };
    state.webSocketChannel!.sink.add(jsonEncode(statusUpdate));
  }
}

final chatProvider = NotifierProvider<ChatNotifier, ChatState>(ChatNotifier.new);
