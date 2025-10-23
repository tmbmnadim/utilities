import 'package:utilities/utils/data_state.dart';
import 'package:utilities/utils/repository_error_handler.dart';

import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/ai_repository.dart';
import '../datasources/openai_remote_data_source.dart';
import '../models/chat_message_model.dart';

class AIRepositoryImpl implements AIRepository {
  final OpenAIRemoteDataSource remoteDataSource;

  AIRepositoryImpl(this.remoteDataSource);

  @override
  Future<DataState<String>> initialize() {
    return RepositoryErrorHandler.call<String>(
      network: remoteDataSource.initialize,
      cacheKey: 'ai_model',
      proxyMessage: "Something went wrong!",
    );
  }

  @override
  Future<DataState<ChatMessage>> sendMessage(
    String prompt, {
    required List<ChatMessage> history,
    required String model,
  }) async {
    return RepositoryErrorHandler.call<ChatMessage>(
      network: () {
        final historyModels = history
            .map((m) => ChatMessageModel.fromEntity(m))
            .toList();
        return remoteDataSource.sendPrompt(
          prompt,
          history: historyModels,
          model: model,
        );
      },
      proxyMessage: "Something went wrong!",
    );
  }
}
