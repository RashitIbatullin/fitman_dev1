enum ChatType {
  peerToPeer,
  group,
}

class Chat {
  final String id;
  final String? name;
  final ChatType type;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  Chat({
    required this.id,
    this.name,
    required this.type,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'].toString(),
      name: json['name']?.toString(),
      type: ChatType.values[json['type'] as int],
      createdBy: json['created_by']?.toString(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.index,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
