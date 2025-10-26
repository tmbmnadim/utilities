class LiveUser {
  final String id;
  final String name;

  LiveUser({required this.id, required this.name});

  factory LiveUser.fromJson(Map<String, dynamic> json) {
    return LiveUser(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}
