import 'package:equatable/equatable.dart';

abstract class AiChatEvent extends Equatable {
  const AiChatEvent();

  @override
  List<Object?> get props => [];
}

class InitializeAIChat extends AiChatEvent {}

class SendMessagePressed extends AiChatEvent {
  final String prompt;

  const SendMessagePressed(this.prompt);

  @override
  List<Object?> get props => [prompt];
}

class AiChatCleared extends AiChatEvent {}
