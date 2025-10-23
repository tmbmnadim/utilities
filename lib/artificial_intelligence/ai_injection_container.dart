import 'package:get_it/get_it.dart';

import 'data/datasources/openai_remote_data_source.dart';
import 'data/repositories/ai_repository_impl.dart';
import 'domain/repositories/ai_repository.dart';
import 'domain/usecases/intialize_ai_chat.dart';
import 'domain/usecases/send_message_usecase.dart';
import 'presentation/bloc/ai_chat_bloc.dart';

final sl = GetIt.instance;

Future<void> initAI() async {
  // Data sources
  sl.registerLazySingleton<OpenAIRemoteDataSource>(
    () => OpenAIRemoteDataSourceImpl(),
  );

  // Repository
  sl.registerLazySingleton<AIRepository>(() => AIRepositoryImpl(sl()));

  // Use case
  sl.registerLazySingleton<SendMessageUseCase>(() => SendMessageUseCase(sl()));
  sl.registerLazySingleton<InitializeAiChatUC>(() => InitializeAiChatUC(sl()));

  // Bloc
  sl.registerFactory<AiChatBloc>(() => AiChatBloc(sl(), sl()));
}
