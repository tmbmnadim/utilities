import '../../domain/entities/chat_message.dart';

class AiMessageModel extends AiMessage {
  const AiMessageModel({
    required super.id,
    required super.content,
    required super.isUser,
    required super.timestamp,
  });

  factory AiMessageModel.fromEntity(AiMessage entity) {
    return AiMessageModel(
      id: entity.id,
      content: entity.content,
      isUser: entity.isUser,
      timestamp: entity.timestamp,
    );
  }

  AiMessage toEntity() => AiMessage(
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
