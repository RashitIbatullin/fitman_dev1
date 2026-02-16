import 'package:http/http.dart' as http;

import '../../modules/chat/models/chat_models.dart';
import 'base_api.dart';

/// Service class for chat-related APIs.
class ChatApiService extends BaseApiService {
  ChatApiService({super.client});

  /// Fetches the list of chats for the current user.
  Future<List<Chat>> getChats() async {
    final data = await get('/api/chats');
    return (data as List).map((chatJson) => Chat.fromJson(chatJson)).toList();
  }

  /// Fetches messages for a specific chat.
  Future<List<Message>> getMessages(int chatId, {int limit = 50, int offset = 0}) async {
    final data = await get('/api/chats/$chatId/messages', queryParams: {
      'limit': limit.toString(),
      'offset': offset.toString(),
    });
    return (data as List).map((msgJson) => Message.fromJson(msgJson)).toList();
  }

  /// Creates a new private chat with a peer or retrieves the existing one.
  Future<int> createOrGetPrivateChat(int peerId) async {
    final data = await post('/api/chats/private', body: {'peerId': peerId});
    return data['chat_id'] as int;
  }

  /// Creates a new group chat.
  Future<Chat> createGroupChat(String name, List<int> memberIds) async {
    final data = await post('/api/chats/group', body: {
      'name': name,
      'member_ids': memberIds,
    });
    return Chat.fromJson(data);
  }

  /// Uploads an attachment to a chat.
  Future<Message> uploadChatAttachment({
    required int chatId,
    required List<int> fileBytes,
    required String fileName,
  }) async {
    final file = http.MultipartFile.fromBytes('attachment', fileBytes, filename: fileName);
    final data = await multipartPost(
      '/api/chats/$chatId/attachments',
      fields: {},
      file: file,
    );
    return Message.fromJson(data);
  }
}