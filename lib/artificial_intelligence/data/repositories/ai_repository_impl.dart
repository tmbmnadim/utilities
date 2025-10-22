import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/ai_repository.dart';
import '../datasources/openai_remote_data_source.dart';
import '../models/chat_message_model.dart';

class AIRepositoryImpl implements AIRepository {
  final OpenAIRemoteDataSource remoteDataSource;

  AIRepositoryImpl(this.remoteDataSource);

  @override
  Future<ChatMessage> sendMessage(String prompt, List<ChatMessage> history) async {
    final historyModels = history
        .map((m) => ChatMessageModel.fromEntity(m))
        .toList();

    final response = await remoteDataSource.sendPrompt(prompt, historyModels);

    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: response,
      isUser: false,
      timestamp: DateTime.now(),
    );
  }
}
