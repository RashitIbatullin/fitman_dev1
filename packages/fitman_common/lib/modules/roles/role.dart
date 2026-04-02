class Role {
  final String id;
  final String name;
  final String title;
  final String? icon;

  Role({required this.id, required this.name, required this.title, this.icon});

  factory Role.fromMap(Map<String, dynamic> map) => Role.fromJson(map);

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'].toString(),
      name: json['name'].toString(),
      title: json['title'].toString(),
      icon: json['icon']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'title': title, 'icon': icon};
  }
}
