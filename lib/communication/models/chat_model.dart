import 'message_model.dart';

class ChatModel {
  final String id;
  final String name;
  final ChatMessageModel lastMessage;
  final DateTime time;
  final int unreadCount;
  final bool isOnline;

  // --- New Fields ---
  final bool isGroup;
  final List<String> participantIds;

  ChatModel({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.time,
    this.unreadCount = 0,
    this.isOnline = false,
    this.isGroup = false,
    this.participantIds = const [],
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'] as String,
      name: json['name'] as String,
      lastMessage: ChatMessageModel.fromMap(
        json['lastMessage'] as Map<String, dynamic>,
      ),
      time: DateTime.parse(json['time'] as String),
      unreadCount: json['unreadCount'] as int? ?? 0,
      isOnline: json['isOnline'] as bool? ?? false,
      isGroup: json['isGroup'] as bool? ?? false,
      participantIds: json['participantIds'] != null
          ? List<String>.from(json['participantIds'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'lastMessage': lastMessage.toMap(),
      'time': time.toIso8601String(),
      'unreadCount': unreadCount,
      'isOnline': isOnline,
      'isGroup': isGroup,
      'participantIds': participantIds,
    };
  }

  ChatModel copyWith({
    String? id,
    String? name,
    ChatMessageModel? lastMessage,
    DateTime? time,
    int? unreadCount,
    bool? isOnline,
    bool? isGroup,
    List<String>? participantIds,
  }) {
    return ChatModel(
      id: id ?? this.id,
      name: name ?? this.name,
      lastMessage: lastMessage ?? this.lastMessage,
      time: time ?? this.time,
      unreadCount: unreadCount ?? this.unreadCount,
      isOnline: isOnline ?? this.isOnline,
      isGroup: isGroup ?? this.isGroup,
      participantIds: participantIds ?? this.participantIds,
    );
  }

  @override
  String toString() =>
      'ChatModel(id: $id, name: $name, lastMessage: $lastMessage, time: $time, unreadCount: $unreadCount, isOnline: $isOnline)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          lastMessage == other.lastMessage &&
          time == other.time &&
          unreadCount == other.unreadCount &&
          isOnline == other.isOnline;

  @override
  int get hashCode =>
      Object.hash(id, name, lastMessage, time, unreadCount, isOnline);
}
