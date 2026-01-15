import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:utilities/communication/models/chat_model.dart';
import 'package:utilities/theme/ml_theme.dart';

class ChatPreviewTile extends StatelessWidget {
  final ChatModel chat;
  final VoidCallback onTap;

  const ChatPreviewTile({super.key, required this.chat, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      onTap: onTap,
      leading: _buildAvatar(),
      title: Text(
        chat.name,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: ChatColors.textDark,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(
          chat.lastMessage.content,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: chat.unreadCount > 0
                ? ChatColors.textDark
                : ChatColors.textLight,
            fontWeight: chat.unreadCount > 0
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
      ),
      trailing: _buildTrailingInfo(),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: const BoxDecoration(
            color: ChatColors.primaryLight,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person, color: ChatColors.primary, size: 28),
        ),
        if (chat.isOnline)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTrailingInfo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          DateFormat.Hm().format(chat.time),
          style: const TextStyle(fontSize: 12, color: ChatColors.textLight),
        ),
        if (chat.unreadCount > 0) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: ChatColors.primary,
              shape: BoxShape.circle,
            ),
            child: Text(
              chat.unreadCount.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
