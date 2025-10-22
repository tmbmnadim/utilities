import 'package:dart_openai/dart_openai.dart';
import '../models/chat_message_model.dart';

abstract class OpenAIRemoteDataSource {
  Future<String> sendPrompt(String prompt, List<ChatMessageModel> history);
}

class OpenAIRemoteDataSourceImpl implements OpenAIRemoteDataSource {
  @override
  Future<String> sendPrompt(
    String prompt,
    List<ChatMessageModel> history,
  ) async {
    final messages = [
      ...history.map(
        (m) => {"role": m.isUser ? "user" : "assistant", "content": m.content},
      ),
      {"role": "user", "content": prompt},
    ];

    final chatCompletion = await OpenAI.instance.chat.create(
      model: "gpt-3.5-turbo",
      messages: messages
          .map(
            (m) => OpenAIChatCompletionChoiceMessageModel(
              role:OpenAIChatMessageRole.assistant,
              content: [
                OpenAIChatCompletionChoiceMessageContentItemModel.text(
                  m["content"]!,
                ),
              ],
            ),
          )
          .toList(),
    );

    return chatCompletion.choices.first.message.content?.first.text?.trim() ??
        '';
  }
}
