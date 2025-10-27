class LiveUser {
  final String id;
  final String name;
  final DateTime createdAt;

  LiveUser({required this.id, required this.name, required this.createdAt});

  factory LiveUser.fromJson(Map<String, dynamic> json) {
    return LiveUser(
      id: json['id'],
      name: json['name'],
      createdAt: DateTime.tryParse(json['createdAt'])??DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {'name': name};
}
