enum MessageStatusValue {
  sent,
  delivered,
  read,
}

class MessageStatus {
  final int id;
  final int messageId;
  final int userId;
  final MessageStatusValue status;
  final DateTime createdAt;

  MessageStatus({
    required this.id,
    required this.messageId,
    required this.userId,
    required this.status,
    required this.createdAt,
  });

  factory MessageStatus.fromJson(Map<String, dynamic> json) {
    return MessageStatus(
      id: json['id'],
      messageId: json['message_id'],
      userId: json['user_id'],
      status: MessageStatusValue.values[json['status']],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message_id': messageId,
      'user_id': userId,
      'status': status.index,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
