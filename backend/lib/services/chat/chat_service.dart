import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:postgres/postgres.dart';
import 'package:fitman_common/modules/chat/chat_models.dart';
import '../../../config/database.dart'; // Assuming database connection for user checks or message storage

class ChatService {
  ChatService(this._db);

  final Database _db;
  final _connections = <String, WebSocketChannel>{}; // Maps userId to WebSocketChannel

  // When a user connects, store their connection
  void handleConnection(String userId, WebSocketChannel channel) {
    print('[ChatService] User connected: $userId');
    _connections[userId] = channel;

    channel.stream.listen(
      (data) => _handleMessage(userId, data),
      onDone: () => removeConnection(userId),
      onError: (error) {
        print('[ChatService] Error for user $userId: $error');
        removeConnection(userId);
      },
    );
  }

  // When a user disconnects, remove their connection
  void removeConnection(String userId) {
    print('[ChatService] User disconnected: $userId');
    _connections.remove(userId);
  }

  // Handle incoming messages from a user
  Future<void> _handleMessage(String senderId, dynamic data) async {
    try {
      final messageData = jsonDecode(data as String);
      final chatId = messageData['chat_id'] as String?;
      final content = messageData['content'] as String?;
      final attachmentUrl = messageData['attachment_url'] as String?;
      final attachmentType = messageData['attachment_type'] as String?;
      
      if (chatId == null) return;
      if (content == null && attachmentUrl == null) return;

      // 1. Save the message to the database
      final savedMessage = await _saveMessageToDb(
        chatId: chatId,
        senderId: senderId,
        content: content,
        attachmentUrl: attachmentUrl,
        attachmentType: attachmentType,
      );

      // 2. Get all participants of the chat
      final participants = await _getChatParticipants(chatId);

      // 3. Broadcast the message to all online participants
      for (final participantId in participants) {
        final recipientSocket = _connections[participantId];
        if (recipientSocket != null) {
          // Manually construct the JSON to match Message.fromJson
          recipientSocket.sink.add(jsonEncode({
            'type': 'new_message',
            'id': savedMessage.id,
            'chat_id': savedMessage.chatId,
            'sender_id': savedMessage.senderId,
            'content': savedMessage.content,
            'attachment_url': savedMessage.attachmentUrl,
            'attachment_type': savedMessage.attachmentType,
            'created_at': savedMessage.createdAt.toIso8601String(),
            'first_name': savedMessage.firstName,
            'last_name': savedMessage.lastName,
          }));
        }
      }
    } catch (e) {
      print('[ChatService] Error handling message: $e');
    }
  }

  Future<Message> _saveMessageToDb({
    required String chatId,
    required String senderId,
    String? content,
    String? attachmentUrl,
    String? attachmentType,
  }) async {
    final conn = await _db.connection;
    final result = await conn.execute(
      Sql.named('''
        INSERT INTO messages (chat_id, sender_id, content, attachment_url, attachment_type)
        VALUES (@chatId, @senderId, @content, @attachmentUrl, @attachmentType)
        RETURNING id, chat_id, sender_id, content, attachment_url, attachment_type, created_at
      '''),
      parameters: {
        'chatId': chatId,
        'senderId': senderId,
        'content': content,
        'attachmentUrl': attachmentUrl,
        'attachmentType': attachmentType,
      },
    );

    final savedRow = result.first.toColumnMap();
    final sender = await _db.users.getUserById(senderId);

    return Message(
      id: savedRow['id'],
      chatId: savedRow['chat_id'],
      senderId: savedRow['sender_id'],
      content: savedRow['content'],
      createdAt: savedRow['created_at'],
      attachmentUrl: savedRow['attachment_url'],
      attachmentType: savedRow['attachment_type'],
      firstName: sender?.firstName,
      lastName: sender?.lastName,
    );
  }

  Future<List<String>> _getChatParticipants(String chatId) async {
    final conn = await _db.connection;
    final results = await conn.execute(
      Sql.named('SELECT user_id FROM chat_participants WHERE chat_id = @chatId'),
      parameters: {'chatId': chatId},
    );
    return results.map((row) => row[0] as String).toList();
  }

  // A static instance for singleton access
  static final ChatService _instance = ChatService(Database());
  static ChatService get instance => _instance;
}
