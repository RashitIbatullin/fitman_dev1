class Role {
  final int id;
  final String name;
  final String title;
  final String? icon;

  Role({
    required this.id,
    required this.name,
    required this.title,
    this.icon,
  });

  factory Role.fromMap(Map<String, dynamic> map) {
    return Role(
      id: map['id'] is int ? map['id'] : int.parse(map['id'].toString()),
      name: map['name'].toString(),
      title: map['title'].toString(),
      icon: map['icon']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'title': title,
      'icon': icon,
    };
  }
}