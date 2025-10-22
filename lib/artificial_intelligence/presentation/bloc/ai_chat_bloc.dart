import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/usecases/send_message_usecase.dart';
import 'ai_chat_event.dart';
import 'ai_chat_state.dart';

class AiChatBloc extends Bloc<AiChatEvent, AiChatState> {
  final SendMessageUseCase sendMessageUseCase;

  AiChatBloc(this.sendMessageUseCase) : super(const AiChatState()) {
    on<AiChatInitialized>(_onInitialized);
    on<AiChatMessageSent>(_onMessageSent);
    on<AiChatCleared>(_onCleared);
  }

  void _onInitialized(AiChatInitialized event, Emitter<AiChatState> emit) {
    emit(const AiChatState(status: AiChatStatus.initial, messages: []));
  }

  Future<void> _onMessageSent(AiChatMessageSent event, Emitter<AiChatState> emit) async {
    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: event.prompt,
      isUser: true,
      timestamp: DateTime.now(),
    );

    final updated = [...state.messages, userMsg];
    emit(state.copyWith(status: AiChatStatus.loading, messages: updated));

    try {
      final aiMsg = await sendMessageUseCase(event.prompt, updated);
      emit(state.copyWith(
        status: AiChatStatus.success,
        messages: [...updated, aiMsg],
      ));
    } catch (e) {
      emit(state.copyWith(status: AiChatStatus.error, error: e.toString()));
    }
  }

  void _onCleared(AiChatCleared event, Emitter<AiChatState> emit) {
    emit(const AiChatState(status: AiChatStatus.initial, messages: []));
  }
}
