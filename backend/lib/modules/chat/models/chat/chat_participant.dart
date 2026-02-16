enum ParticipantRole {
  member,
  admin,
}

class ChatParticipant {
  final int id;
  final int chatId;
  final int userId;
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
      id: json['id'],
      chatId: json['chat_id'],
      userId: json['user_id'],
      role: json['role'] != null ? ParticipantRole.values[json['role']] : null,
      joinedAt: DateTime.parse(json['joined_at']),
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
