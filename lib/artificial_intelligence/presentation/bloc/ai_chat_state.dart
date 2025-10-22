import 'package:equatable/equatable.dart';
import '../../domain/entities/chat_message.dart';

enum AiChatStatus { initial, loading, success, error }

class AiChatState extends Equatable {
  final AiChatStatus status;
  final List<ChatMessage> messages;
  final String? error;

  const AiChatState({
    this.status = AiChatStatus.initial,
    this.messages = const [],
    this.error,
  });

  AiChatState copyWith({
    AiChatStatus? status,
    List<ChatMessage>? messages,
    String? error,
  }) {
    return AiChatState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, messages, error];
}
