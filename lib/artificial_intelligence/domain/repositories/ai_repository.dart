import 'package:utilities/utils/data_state.dart';

import '../entities/chat_message.dart';

abstract class AIRepository {
  Future<DataState<void>> initialize();
  Future<DataState<AiMessage>> sendMessage(
    String prompt, {
    required List<AiMessage> history,
    required String model,
  });
}
