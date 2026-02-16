enum ChatType {
  peerToPeer,
  group,
}

class Chat {
  final int id;
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
      id: json['id'],
      name: json['name'],
      type: ChatType.values[json['type']],
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

class Message {
  final int id;
  final int chatId;
  final int senderId;
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
      id: json['id'],
      chatId: json['chat_id'],
      senderId: json['sender_id'],
      content: json['content'],
      attachmentUrl: json['attachment_url'],
      attachmentType: json['attachment_type'],
      createdAt: DateTime.parse(json['created_at']),
      firstName: json['first_name'],
      lastName: json['last_name'],
    );
  }
}
