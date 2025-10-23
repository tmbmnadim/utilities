import 'package:utilities/utils/data_state.dart';

import '../entities/chat_message.dart';

abstract class AIRepository {
  Future<DataState<void>> initialize();
  Future<DataState<ChatMessage>> sendMessage(
    String prompt, {
    required List<ChatMessage> history,
    required String model,
  });
}
