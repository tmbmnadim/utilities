import 'package:dart_openai/dart_openai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/chat_message_model.dart';

abstract class OpenAIRemoteDataSource {
  Future<String> initialize();
  Future<ChatMessageModel> sendPrompt(
    String prompt, {
    required List<ChatMessageModel> history,
    required String model,
  });
}

class OpenAIRemoteDataSourceImpl implements OpenAIRemoteDataSource {
  @override
  Future<String> initialize() async {
    final apiKey = dotenv.env["OPEN_AI_API_KEY"];
    if (apiKey == null) throw Exception("Api key is empty!");

    // Assigning API Key
    OpenAI.apiKey = apiKey;

    // Fetching available list of models
    final models = await OpenAI.instance.model.list();
    if (models.isEmpty) throw Exception("No models found!");

    for (var model in models) {
      if (model.havePermission) {
        return model.id;
      }
    }
    throw Exception("No working model found!");
  }

  @override
  Future<ChatMessageModel> sendPrompt(
    String prompt, {
    required List<ChatMessageModel> history,
    required String model,
  }) async {
    final messages = [
      ...history.map(
        (h) => {
          "role": h.isUser
              ? OpenAIChatMessageRole.user
              : OpenAIChatMessageRole.assistant,
          "content": h.content,
        },
      ),
      {"role": OpenAIChatMessageRole.user, "content": prompt},
    ];

    final chatCompletion = await OpenAI.instance.chat.create(
      model: model,
      messages: messages
          .map(
            (m) => OpenAIChatCompletionChoiceMessageModel(
              role: m["role"]! as OpenAIChatMessageRole,
              content: [
                OpenAIChatCompletionChoiceMessageContentItemModel.text(
                  m["content"]! as String,
                ),
              ],
            ),
          )
          .toList(),
    );

    final output = ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content:
          chatCompletion.choices.first.message.content?.first.text?.trim() ??
          '',
      isUser: false,
      timestamp: DateTime.now(),
    );

    return output;
  }
}
