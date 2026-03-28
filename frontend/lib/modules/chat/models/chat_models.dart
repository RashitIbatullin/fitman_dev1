enum ChatType {
  peerToPeer,
  group,
}

class Chat {
  final String id;
  final String? name;
  final ChatType type;
  final DateTime updatedAt;
  // Поля для UI
  String? lastMessage;
  int unreadCount;

  Chat({
    required this.id,
    this.name,
    required this.type,
    required this.updatedAt,
    this.lastMessage,
    this.unreadCount = 0,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'].toString(),
      name: json['name']?.toString(),
      type: ChatType.values[json['type'] as int],
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

class Message {
  final String id;
  final String chatId;
  final String senderId;
  final String? content;
  final String? attachmentUrl;
  final String? attachmentType;
  final DateTime createdAt;
  final String? firstName; // Имя отправителя
  final String? lastName;  // Фамилия отправителя

  Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    this.content,
    this.attachmentUrl,
    this.attachmentType,
    required this.createdAt,
    this.firstName,
    this.lastName,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'].toString(),
      chatId: json['chat_id'].toString(),
      senderId: json['sender_id'].toString(),
      content: json['content']?.toString(),
      attachmentUrl: json['attachment_url']?.toString(),
      attachmentType: json['attachment_type']?.toString(),
      createdAt: DateTime.parse(json['created_at'] as String),
      firstName: json['first_name']?.toString(),
      lastName: json['last_name']?.toString(),
    );
  }
}
