import '../entities/chat_message.dart';

abstract class AIRepository {
  Future<ChatMessage> sendMessage(String prompt, List<ChatMessage> history);
}
