import 'dart:convert';

import 'package:postgres/postgres.dart';

import '../../../config/database.dart'; // Adjusted relative path
import '../../../services/redis_service.dart'; // Adjusted relative path

class ChatWsController { // Renamed class
  ChatWsController(this._db, this._redis);

  final Database _db;
  final RedisService _redis;

  Future<List<int>> getChatIdsForUser(int userId) async {
    final dbConnection = await _db.connection;
    final chatIdsResult = await dbConnection.execute(
      Sql.named('SELECT chat_id FROM chat_participants WHERE user_id = @userId'),
      parameters: {'userId': userId},
    );
    return chatIdsResult.map((row) => row.first as int).toList();
  }

  Future<Map<String, dynamic>> createChat(List<int> userIds, String? name, int creatorId) async {
    final dbConnection = await _db.connection;

    if (!userIds.contains(creatorId)) {
      userIds.add(creatorId);
    }
    final uniqueUserIds = userIds.toSet().toList();

    if (uniqueUserIds.length < 2) {
      throw ArgumentError('A chat must have at least two participants.');
    }

    if (uniqueUserIds.length == 2) {
      final result = await dbConnection.execute(
        Sql.named('''
          SELECT cp1.chat_id
          FROM chat_participants cp1
          JOIN chat_participants cp2 ON cp1.chat_id = cp2.chat_id
          WHERE cp1.user_id = @user1 AND cp2.user_id = @user2
            AND (SELECT COUNT(*) FROM chat_participants WHERE chat_id = cp1.chat_id) = 2
        '''),
        parameters: {'user1': uniqueUserIds[0], 'user2': uniqueUserIds[1]},
      );
      if (result.isNotEmpty) {
        final existingChatId = result.first[0] as int;
        return {'id': existingChatId, 'existed': true};
      }
    }

    final int newChatId = await dbConnection.runTx((ctx) async {
       final chatType = uniqueUserIds.length == 2 ? 0 : 1; // 0 for P2P, 1 for Group
       final chatResult = await ctx.execute(
          Sql.named('''
            INSERT INTO chats (name, type, created_by)
            VALUES (@name, @type, @creatorId)
            RETURNING id
          '''),
          parameters: {'name': name, 'type': chatType, 'creatorId': creatorId},
       );
      final chatId = chatResult.first[0] as int;

      for (final userId in uniqueUserIds) {
        await ctx.execute(
          Sql.named('''
            INSERT INTO chat_participants (chat_id, user_id, role)
            VALUES (@chatId, @userId, @role)
          '''),
          parameters: {'chatId': chatId, 'userId': userId, 'role': 0}, // Default role 0 for participant
        );
      }
      return chatId;
    });
    
    return {'id': newChatId, 'existed': false};
  }

  Future<void> handleWebSocketMessage({
    required String message,
    required int userId,
    required List<int> userChatIds,
    required String? userFirstName,
    required String? userLastName,
  }) async {
    final data = jsonDecode(message);
    final type = data['type'] as String?;

    switch (type) {
      case 'status_update':
        await _handleStatusUpdate(data, userId, userChatIds);
        break;
      default:
        await _handleNewMessage(
          data,
          userId,
          userChatIds,
          userFirstName,
          userLastName,
          attachmentUrl: data['attachment_url'] as String?,
          attachmentType: data['attachment_type'] as String?,
        );
    }
  }

  Future<void> _handleNewMessage(
    Map<String, dynamic> data,
    int userId,
    List<int> userChatIds,
    String? userFirstName,
    String? userLastName, {
    String? attachmentUrl,
    String? attachmentType,
  }) async {
    final chatId = data['chat_id'] as int?;
    final content = data['content'] as String?;

    if (chatId == null || (content == null && attachmentUrl == null) || (content != null && content.trim().isEmpty && attachmentUrl == null)) {
      throw ArgumentError('Invalid message format. Required: {"chat_id": 123, "content": "..."} or {"chat_id": 123, "attachment_url": "...", "attachment_type": "..."}');
    }

    if (!userChatIds.contains(chatId)) {
      throw ArgumentError('You are not a member of chat $chatId.');
    }

    final dbConnection = await _db.connection;
    final result = await dbConnection.execute(
      Sql.named('''
        INSERT INTO messages (chat_id, sender_id, content, attachment_url, attachment_type)
        VALUES (@chatId, @senderId, @content, @attachmentUrl, @attachmentType)
        RETURNING id, created_at
      '''),
      parameters: {
        'chatId': chatId,
        'senderId': userId,
        'content': content,
        'attachmentUrl': attachmentUrl,
        'attachmentType': attachmentType,
      },
    );

    final newMsgId = result.first.toColumnMap()['id'];
    final newMsgCreatedAt = result.first.toColumnMap()['created_at'] as DateTime;

    final outgoingMessage = {
      'type': 'new_message',
      'id': newMsgId,
      'chat_id': chatId,
      'sender_id': userId,
      'content': content,
      'created_at': newMsgCreatedAt.toIso8601String(),
      'first_name': userFirstName,
      'last_name': userLastName,
      'attachment_url': attachmentUrl,
      'attachment_type': attachmentType,
    };

    await _redis.publish('chat:$chatId', jsonEncode(outgoingMessage));
  }

  Future<void> _handleStatusUpdate(Map<String, dynamic> data, int userId, List<int> userChatIds) async {
    final messageId = data['message_id'] as int?;
    final status = data['status'] as String?;
    final chatId = data['chat_id'] as int?;

    if (messageId == null || status == null || chatId == null) {
      throw ArgumentError('Invalid status update format. Required: {"type": "status_update", "chat_id": 123, "message_id": 456, "status": "read"}');
    }
    
    if (!userChatIds.contains(chatId)) {
      throw ArgumentError('You are not a member of chat $chatId.');
    }

    final dbConnection = await _db.connection;
    await dbConnection.execute(
      Sql.named('''
        INSERT INTO message_statuses (message_id, user_id, status)
        VALUES (@messageId, @userId, @status)
        ON CONFLICT (message_id, user_id) DO UPDATE SET status = @status
      '''),
      parameters: {'messageId': messageId, 'userId': userId, 'status': status},
    );

    final outgoingStatusUpdate = {
      'type': 'status_update',
      'message_id': messageId,
      'user_id': userId,
      'status': status,
      'chat_id': chatId,
    };

    await _redis.publish('chat:$chatId', jsonEncode(outgoingStatusUpdate));
  }

  Future<List<Map<String, dynamic>>> getMessages(int chatId, int userId, {int limit = 50, int offset = 0}) async {
    final dbConnection = await _db.connection;
    
    // Check if user is a participant
    final participationCheck = await dbConnection.execute(
      Sql.named('SELECT 1 FROM chat_participants WHERE chat_id = @chatId AND user_id = @userId'),
      parameters: {'chatId': chatId, 'userId': userId},
    );

    if (participationCheck.isEmpty) {
      throw ArgumentError('You are not a member of chat $chatId.');
    }

    final results = await dbConnection.execute(
      Sql.named('''
        SELECT 
          m.id,
          m.chat_id,
          m.sender_id,
          m.content,
          m.created_at,
          u.first_name,
          u.last_name
        FROM messages m
        JOIN users u ON m.sender_id = u.id
        WHERE m.chat_id = @chatId
        ORDER BY m.created_at DESC
        LIMIT @limit
        OFFSET @offset
      '''),
      parameters: {'chatId': chatId, 'limit': limit, 'offset': offset},
    );

    return results.map((row) {
      final map = row.toColumnMap();
      map['created_at'] = (map['created_at'] as DateTime).toIso8601String();
      return map;
    }).toList();
  }
}