enum ChatType {
  peerToPeer,
  group,
}

class Chat {
  final int id;
  final String? name;
  final ChatType type;
  final int? createdBy;
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
      id: json['id'],
      name: json['name'],
      type: ChatType.values[json['type']],
      createdBy: json['created_by'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
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
