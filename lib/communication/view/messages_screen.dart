import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:utilities/communication/controllers/chat_controller.dart';
import 'package:utilities/theme/ml_theme.dart';

import '../models/chat_model.dart';
import '../models/message_model.dart';
import 'widgets/chat_input_bar.dart';
import 'widgets/message_bubble.dart';

class MessagesScreen extends StatefulWidget {
  final ChatModel chat;
  const MessagesScreen({super.key, required this.chat});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 60,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ChatColors.background,
      appBar: AppBar(
        backgroundColor: ChatColors.surface,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ChatColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: _buildAppBarTitle(),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.videocam_outlined,
              color: ChatColors.primary,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.call_outlined, color: ChatColors.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: GetBuilder<ChatController>(
        builder: (chatCtrl) {
          final selectedChat = chatCtrl.selectedChat;
          List<ChatMessageModel> messages =
              chatCtrl.state.messages[selectedChat!.id] ?? [];
          final user = chatCtrl.state.user;
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return MessageBubble(
                      message: messages[index],
                      userId: user?.id ?? "",
                    );
                  },
                ),
              ),
              ChatInputBar(
                controller: _msgCtrl,
                onSendPressed: () => chatCtrl.sendTextMessage(_msgCtrl.text),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBarTitle() {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: ChatColors.primaryLight,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.smart_toy,
            color: ChatColors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.chat.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ChatColors.textDark,
              ),
            ),
            Text(
              widget.chat.isOnline ? 'Online' : 'Offline',
              style: TextStyle(
                fontSize: 12,
                color: widget.chat.isOnline ? ChatColors.primary : Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
