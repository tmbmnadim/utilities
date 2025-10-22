import 'package:equatable/equatable.dart';

abstract class AiChatEvent extends Equatable {
  const AiChatEvent();

  @override
  List<Object?> get props => [];
}

class AiChatInitialized extends AiChatEvent {}

class AiChatMessageSent extends AiChatEvent {
  final String prompt;

  const AiChatMessageSent(this.prompt);

  @override
  List<Object?> get props => [prompt];
}

class AiChatCleared extends AiChatEvent {}
