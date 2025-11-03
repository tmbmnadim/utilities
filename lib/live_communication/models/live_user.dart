class LiveUser {
  final String id;
  final String name;
  final bool isOnline;
  final DateTime createdAt;

  LiveUser({
    required this.id,
    required this.name,
    this.isOnline = false,
    required this.createdAt,
  });

  factory LiveUser.fromJson(Map<String, dynamic> json) {
    return LiveUser(
      id: json['id'],
      name: json['name'],
      isOnline: json['is_online'] ?? false,
      createdAt: DateTime.tryParse(json['created_at']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'is_online': isOnline,
    'created_at': createdAt,
  };
}
