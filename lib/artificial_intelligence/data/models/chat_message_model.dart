import '../../domain/entities/chat_message.dart';

class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    required super.id,
    required super.content,
    required super.isUser,
    required super.timestamp,
  });

  factory ChatMessageModel.fromEntity(ChatMessage entity) {
    return ChatMessageModel(
      id: entity.id,
      content: entity.content,
      isUser: entity.isUser,
      timestamp: entity.timestamp,
    );
  }

  ChatMessage toEntity() => ChatMessage(
        id: id,
        content: content,
        isUser: isUser,
        timestamp: timestamp,
      );

  Map<String, dynamic> toMap() => {
        "role": isUser ? "user" : "assistant",
        "content": content,
      };
}
