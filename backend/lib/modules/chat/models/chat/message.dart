class Message {
  final int id;
  final int chatId;
  final int senderId;
  final String? content;
  final String? attachmentUrl;
  final String? attachmentType;
  final DateTime createdAt;
  final int? parentMessageId;

  Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    this.content,
    this.attachmentUrl,
    this.attachmentType,
    required this.createdAt,
    this.parentMessageId,
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
      parentMessageId: json['parent_message_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chat_id': chatId,
      'sender_id': senderId,
      'content': content,
      'attachment_url': attachmentUrl,
      'attachment_type': attachmentType,
      'created_at': createdAt.toIso8601String(),
      'parent_message_id': parentMessageId,
    };
  }
}
