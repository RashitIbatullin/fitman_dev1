class Role {
  final int id;
  final String name;
  final String title;
  final String? icon;

  Role({required this.id, required this.name, required this.title, this.icon});

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'].toString(),
      title: json['title'].toString(),
      icon: json['icon']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'title': title, 'icon': icon};
  }
}
