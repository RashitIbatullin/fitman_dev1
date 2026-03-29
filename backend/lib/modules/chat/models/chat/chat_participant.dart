enum ParticipantRole {
  member,
  admin,
}

class ChatParticipant {
  final String id;
  final String chatId;
  final String userId;
  final ParticipantRole? role;
  final DateTime joinedAt;

  ChatParticipant({
    required this.id,
    required this.chatId,
    required this.userId,
    this.role,
    required this.joinedAt,
  });

  factory ChatParticipant.fromJson(Map<String, dynamic> json) {
    return ChatParticipant(
      id: json['id'].toString(),
      chatId: json['chat_id'].toString(),
      userId: json['user_id'].toString(),
      role: json['role'] != null ? ParticipantRole.values[json['role'] as int] : null,
      joinedAt: DateTime.parse(json['joined_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chat_id': chatId,
      'user_id': userId,
      'role': role?.index,
      'joined_at': joinedAt.toIso8601String(),
    };
  }
}
