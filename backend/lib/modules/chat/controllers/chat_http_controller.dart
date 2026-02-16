import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:postgres/postgres.dart';
import '../../../config/database.dart'; // Adjusted relative path

class ChatHttpController { // Renamed class
  // Получить все чаты для текущего пользователя
  static Future<Response> getChats(Request request) async {
    try {
      final user = request.context['user'] as Map<String, dynamic>?;
      final userId = user?['userId'] as int?;

      if (userId == null) {
        return Response.badRequest(body: jsonEncode({'error': 'User ID not found in token.'}));
      }

      final db = Database();
      final connection = await db.connection;

      final result = await connection.execute(
        Sql.named('''
          SELECT c.id, c.name, c.type, c.updated_at
          FROM chats c
          JOIN chat_participants cp ON c.id = cp.chat_id
          WHERE cp.user_id = @userId
          ORDER BY c.updated_at DESC
        '''),
        parameters: {'userId': userId},
      );

      final chats = result.map((row) => row.toColumnMap()).toList();

      return Response.ok(jsonEncode(chats));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Error getting chats: $e'}));
    }
  }

  // Получить сообщения для конкретного чата с пагинацией
  static Future<Response> getMessages(Request request, String chatId) async {
    try {
      final user = request.context['user'] as Map<String, dynamic>?;
      final userId = user?['userId'] as int?;
      if (userId == null) {
        return Response.forbidden('Authentication required.');
      }

      final int parsedChatId;
      try {
        parsedChatId = int.parse(chatId);
      } catch (e) {
        return Response.badRequest(body: jsonEncode({'error': 'Invalid chat ID.'}));
      }

      final limit = int.tryParse(request.url.queryParameters['limit'] ?? '50') ?? 50;
      final offset = int.tryParse(request.url.queryParameters['offset'] ?? '0') ?? 0;

      final db = Database();
      final connection = await db.connection;

      // Проверка, является ли пользователь участником чата
      final participantCheck = await connection.execute(
        Sql.named('SELECT 1 FROM chat_participants WHERE chat_id = @chatId AND user_id = @userId'),
        parameters: {'chatId': parsedChatId, 'userId': userId},
      );

      if (participantCheck.isEmpty) {
        return Response.forbidden(jsonEncode({'error': 'You are not a member of this chat.'}));
      }

      final result = await connection.execute(
        Sql.named('''
          SELECT m.*, u.first_name, u.last_name
          FROM messages m
          JOIN users u ON m.sender_id = u.id
          WHERE m.chat_id = @chatId
          ORDER BY m.created_at DESC
          LIMIT @limit OFFSET @offset
        '''),
        parameters: {'chatId': parsedChatId, 'limit': limit, 'offset': offset},
      );

      final messages = result.map((row) {
        final map = row.toColumnMap();
        // Преобразование дат в строку ISO 8601 для JSON
        map['created_at'] = (map['created_at'] as DateTime).toIso8601String();
        return map;
      }).toList();


      return Response.ok(jsonEncode(messages));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Error getting messages: $e'}));
    }
  }

  // Создать или получить существующий личный чат
  static Future<Response> createOrGetPrivateChat(Request request) async {
    try {
      final user = request.context['user'] as Map<String, dynamic>?;
      final userId1 = user?['userId'] as int?;
      if (userId1 == null) {
        return Response.forbidden('Authentication required.');
      }

      final body = await request.readAsString();
      final data = jsonDecode(body);
      final userId2 = data['peerId'] as int?;

      if (userId2 == null) {
        return Response.badRequest(body: jsonEncode({'error': 'peerId is required.'}));
      }
      
      if (userId1 == userId2) {
        return Response.badRequest(body: jsonEncode({'error': 'Cannot create a chat with yourself.'}));
      }

      final db = Database();
      final connection = await db.connection;

      // Ищем существующий P2P чат между двумя пользователями
      final existingChat = await connection.execute(
        Sql.named('''
          SELECT cp1.chat_id
          FROM chat_participants cp1
          JOIN chat_participants cp2 ON cp1.chat_id = cp2.chat_id
          JOIN chats c ON cp1.chat_id = c.id
          WHERE cp1.user_id = @userId1 AND cp2.user_id = @userId2 AND c.type = 0
        '''),
        parameters: {'userId1': userId1, 'userId2': userId2},
      );

      if (existingChat.isNotEmpty) {
        final chatId = existingChat.first.toColumnMap()['chat_id'];
        return Response.ok(jsonEncode({'chat_id': chatId}));
      }

      // Если чат не найден, создаем новый
      final newChatId = await connection.runTx<int>((ctx) async {
        final chatResult = await ctx.execute(
          Sql.named('''
            INSERT INTO chats (type, created_by, created_at, updated_at)
            VALUES (0, @userId, NOW(), NOW()) RETURNING id
          '''),
          parameters: {'userId': userId1},
        );
        final chatId = chatResult.first.toColumnMap()['id'];

        await ctx.execute(
          Sql.named('''
            INSERT INTO chat_participants (chat_id, user_id)
            VALUES (@chatId, @userId1), (@chatId, @userId2)
          '''),
          parameters: {'chatId': chatId, 'userId1': userId1, 'userId2': userId2},
        );
        return chatId;
      });

      return Response.ok(jsonEncode({'chat_id': newChatId}));

    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Error creating or getting chat: $e'}));
    }
  }

  // Создать групповой чат
  static Future<Response> createGroupChat(Request request) async {
    try {
      final user = request.context['user'] as Map<String, dynamic>?;
      final creatorId = user?['userId'] as int?;
      if (creatorId == null) {
        return Response.forbidden('Authentication required.');
      }

      final body = await request.readAsString();
      final data = jsonDecode(body);
      final userIds = List<int>.from(data['userIds'] as List<dynamic>);
      final name = data['name'] as String?;

      if (userIds.length < 2) {
        return Response.badRequest(body: jsonEncode({'error': 'Group chat must have at least two participants.'}));
      }
      
      if (!userIds.contains(creatorId)) {
        userIds.add(creatorId);
      }
      final uniqueUserIds = userIds.toSet().toList();

      final db = Database();
      final connection = await db.connection;

      final newChatId = await connection.runTx<int>((ctx) async {
        final chatResult = await ctx.execute(
          Sql.named('''
            INSERT INTO chats (name, type, created_by, created_at, updated_at)
            VALUES (@name, 1, @creatorId, NOW(), NOW()) RETURNING id
          '''),
          parameters: {'name': name, 'creatorId': creatorId},
        );
        final chatId = chatResult.first.toColumnMap()['id'];

        for (final participantId in uniqueUserIds) {
          await ctx.execute(
            Sql.named('''
              INSERT INTO chat_participants (chat_id, user_id)
              VALUES (@chatId, @userId)
            '''),
            parameters: {'chatId': chatId, 'userId': participantId},
          );
        }
        return chatId;
      });

      return Response.ok(jsonEncode({'chat_id': newChatId}));

    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Error creating group chat: $e'}));
    }
  }
}
