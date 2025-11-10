import 'package:equatable/equatable.dart';

class LiveUser extends Equatable {
  final String id;
  final String name;
  final bool isOnline;
  final DateTime createdAt;

  const LiveUser({
    required this.id,
    required this.name,
    this.isOnline = false,
    required this.createdAt,
  });

  LiveUser copyWith({
    String? id,
    String? name,
    bool? isOnline,
    DateTime? createdAt,
  }) {
    return LiveUser(
      id: id ?? this.id,
      name: name ?? this.name,
      isOnline: isOnline ?? this.isOnline,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory LiveUser.fromJson(Map<String, dynamic> json) {
    return LiveUser(
      id: json['id'] as String,
      name: json['name'] as String,
      isOnline: json['is_online'] ?? false,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'is_online': isOnline,
        'created_at': createdAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [id];
}
