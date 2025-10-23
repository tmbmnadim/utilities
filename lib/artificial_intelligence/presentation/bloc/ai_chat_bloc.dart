import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:utilities/artificial_intelligence/domain/usecases/intialize_ai_chat.dart';
import 'package:utilities/utils/data_state.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/usecases/send_message_usecase.dart';
import 'ai_chat_event.dart';
import 'ai_chat_state.dart';

class AiChatBloc extends Bloc<AiChatEvent, AiChatState> {
  final SendMessageUseCase _sendMessageUseCase;
  final InitializeAiChatUC _initializeAiChat;

  AiChatBloc(this._sendMessageUseCase, this._initializeAiChat)
    : super(const AiChatState()) {
    on<InitializeAIChat>(_onInitialized);
    on<SendMessagePressed>(_onMessageSent);
    on<AiChatCleared>(_onCleared);
  }

  void _onInitialized(InitializeAIChat event, Emitter<AiChatState> emit) async {
    try {
      await Future.delayed(Durations.medium4);
      final datastate = await _initializeAiChat();
      if (datastate is DataSuccess) {
        emit(
          AiChatState(
            status: AiChatStatus.success,
            messages: [],
            model: datastate.getData()!,
          ),
        );
      } else {
        throw "Failed to initialize AI Chat";
      }
    } catch (e, s) {
      emit(state.copyWith(status: AiChatStatus.error, error: e.toString()));
      _errorHandler("_onMessageSent", e, s);
    }
  }

  Future<void> _onMessageSent(
    SendMessagePressed event,
    Emitter<AiChatState> emit,
  ) async {
    try {
      final userMsg = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: event.prompt,
        isUser: true,
        timestamp: DateTime.now(),
      );

      final updated = [...state.messages, userMsg];

      emit(state.copyWith(status: AiChatStatus.loading, messages: updated));

      final aiMsg = await _sendMessageUseCase(
        event.prompt,
        history: updated,
        model: state.model!,
      );
      if (aiMsg is DataSuccess) {
        emit(
          state.copyWith(
            status: AiChatStatus.success,
            messages: [...updated, aiMsg.getData()!],
          ),
        );
      } else {
        throw aiMsg.getMessage("Something went wrong!");
      }
    } catch (e, s) {
      emit(state.copyWith(status: AiChatStatus.error, error: e.toString()));
      _errorHandler("_onMessageSent", e, s);
    }
  }

  void _onCleared(AiChatCleared event, Emitter<AiChatState> emit) {
    emit(const AiChatState(status: AiChatStatus.initial, messages: []));
  }

  void _errorHandler(String methodName, Object error, StackTrace stacktrace) {
    log(
      "AiChatBloc<$methodName>: $error",
      time: DateTime.now(),
      error: error,
      stackTrace: stacktrace,
    );
  }
}
