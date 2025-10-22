import '../entities/chat_message.dart';
import '../repositories/ai_repository.dart';

class SendMessageUseCase {
  final AIRepository repository;

  SendMessageUseCase(this.repository);

  Future<ChatMessage> call(String prompt, List<ChatMessage> history) {
    return repository.sendMessage(prompt, history);
  }
}
