import 'live_message_data.dart';
import 'live_message_type.dart';

class ChatMessageModel {
  final String content;
  final String from;
  final String to;
  final DateTime timestamp;
  final MessageMediaType type;

  ChatMessageModel({
    required this.content,
    required this.timestamp,
    required this.type,
    required this.from,
    required this.to,
  });

  factory ChatMessageModel.fromLiveMessage(
    LiveMessageData data,
    String myUserId,
  ) {
    return ChatMessageModel(
      content: data.content ?? '',
      timestamp: data.timestamp ?? DateTime.now(),
      type: data.contentType ?? MessageMediaType.text,
      from: data.from ?? '',
      to: data.to ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'type': type.name,
    };
  }

  factory ChatMessageModel.fromMap(Map<String, dynamic> map) {
    return ChatMessageModel(
      content: map['content'] ?? '',
      timestamp: DateTime.parse(map['timestamp']),
      type: MessageMediaType.values.byName(map['type']),
      from: map['from'],
      to: map['to'],
    );
  }

  ChatMessageModel copyWith({
    String? content,
    String? from,
    String? to,
    bool? isMe,
    DateTime? timestamp,
    MessageMediaType? type,
  }) {
    return ChatMessageModel(
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      from: from ?? this.from,
      to: to ?? this.to,
    );
  }

  @override
  String toString() =>
      'ChatMessageModel(content: $content, from: $from, to: $to, timestamp: $timestamp)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMessageModel &&
          runtimeType == other.runtimeType &&
          content == other.content &&
          from == other.from &&
          to == other.to &&
          timestamp == other.timestamp;

  @override
  int get hashCode => content.hashCode ^ timestamp.hashCode;
}
