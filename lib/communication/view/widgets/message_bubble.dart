import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:utilities/communication/models/message_model.dart';
import 'package:utilities/theme/ml_theme.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessageModel? message;
  final String userId;
  const MessageBubble({super.key, required this.message, required this.userId});

  @override
  Widget build(BuildContext context) {
    final isMe = message?.from == userId;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            const CircleAvatar(
              radius: 14,
              backgroundColor: ChatColors.primaryLight,
              child: Icon(Icons.smart_toy, size: 16, color: ChatColors.primary),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isMe
                    ? ChatColors.myMessageBubble
                    : ChatColors.otherMessageBubble,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha((255 * 0.05).toInt()),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message?.content ?? "This message was not found!",
                    style: TextStyle(
                      fontSize: 15,
                      color: isMe ? Colors.white : ChatColors.textDark,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message == null
                        ? "N/A"
                        : DateFormat.Hm().format(message!.timestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color: isMe
                          ? Colors.white.withAlpha((255 * 0.7).toInt())
                          : ChatColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            const CircleAvatar(
              radius: 14,
              backgroundColor: Color(0xFFE0E0E0),
              child: Icon(Icons.person, size: 16, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }
}
