import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/chat_message.dart';

enum AiChatStatus {
  initial,
  loading,
  success,
  error;

  bool get isInitial => this == initial;
  bool get isLoading => this == loading;
  bool get isSuccess => this == success;
  bool get isError => this == error;
}

@immutable
class AiChatState extends Equatable {
  final AiChatStatus status;
  final List<ChatMessage> messages;
  final String? model;
  final String? error;

  const AiChatState({
    this.status = AiChatStatus.initial,
    this.messages = const [],
    this.model,
    this.error,
  });

  AiChatState copyWith({
    AiChatStatus? status,
    List<ChatMessage>? messages,
    String? model,
    String? error,
  }) {
    return AiChatState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      model: model ?? this.model,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, messages, error];
}
