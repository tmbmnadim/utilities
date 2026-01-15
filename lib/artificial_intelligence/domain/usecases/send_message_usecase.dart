import 'package:utilities/utils/data_state.dart';

import '../entities/chat_message.dart';
import '../repositories/ai_repository.dart';

class SendMessageUseCase {
  final AIRepository repository;

  SendMessageUseCase(this.repository);

  Future<DataState<AiMessage>> call(
    String prompt, {
    required List<AiMessage> history,
    required String model,
  }) {
    return repository.sendMessage(prompt, history: history, model: model);
  }
}
