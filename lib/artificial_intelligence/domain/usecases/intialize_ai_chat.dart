import 'package:utilities/utils/data_state.dart';

import '../repositories/ai_repository.dart';

class InitializeAiChatUC {
  final AIRepository repository;

  InitializeAiChatUC(this.repository);

  Future<DataState<void>> call() {
    return repository.initialize();
  }
}
