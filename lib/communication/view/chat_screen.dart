import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:utilities/artificial_intelligence/presentation/view/ai_base.dart';
import 'package:utilities/communication/controllers/chat_controller.dart';
import 'package:utilities/communication/models/chat_model.dart';
import 'package:utilities/communication/models/message_model.dart';
import 'package:utilities/theme/ml_theme.dart';

import '../models/live_message_type.dart';
import 'messages_screen.dart';
import 'widgets/chat_preview_tile.dart';

class ChatListScreen extends StatelessWidget {
  ChatListScreen({super.key});

  final ChatController _chatCtrl = Get.find<ChatController>();

  final RxBool _isSearching = false.obs;
  final RxString _searchQuery = "".obs;
  final TextEditingController _searchTextCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chatCtrl.loadUsers();
    });

    return Scaffold(
      backgroundColor: ChatColors.background,
      appBar: _buildAppBar(context),
      body: GetBuilder<ChatController>(
        builder: (chatCtrl) => _buildBody(context),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: ChatColors.surface,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.chevron_left_rounded, color: Colors.black),
      ),
      title: Obx(() {
        if (_isSearching.value) {
          return TextField(
            controller: _searchTextCtrl,
            autofocus: true,
            onChanged: (val) => _searchQuery.value = val.trim().toLowerCase(),
            decoration: const InputDecoration(
              hintText: "Search chats...",
              border: InputBorder.none,
              hintStyle: TextStyle(color: ChatColors.textLight),
            ),
            style: const TextStyle(color: ChatColors.textDark),
          );
        }
        return const Text(
          "Chats",
          style: TextStyle(
            color: ChatColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        );
      }),
      actions: [
        Obx(() {
          return IconButton(
            icon: Icon(
              _isSearching.value ? Icons.close : Icons.search,
              color: ChatColors.textDark,
            ),
            onPressed: () async {
              await _chatCtrl.loadUsers();
              _isSearching.value = !_isSearching.value;
              if (!_isSearching.value) {
                _searchQuery.value = "";
                _searchTextCtrl.clear();
              }
            },
          );
        }),
        IconButton(
          icon: const Icon(Icons.edit_square, color: ChatColors.textDark),
          onPressed: () {
            _isSearching.value = true;
          },
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    // 1. Get Data from Controller
    final allChats = _chatCtrl.state.chats;
    final allUsers = _chatCtrl.state.availableUsers; // Users from server
    final query = _searchQuery.value;

    // 2. Filter Active Chats
    final filteredChats = allChats.where((chat) {
      final nameMatch = chat.name.toLowerCase().contains(query);
      final msgMatch = chat.lastMessage.content.toLowerCase().contains(query);
      return nameMatch || msgMatch;
    }).toList();

    // 3. Filter New Users (Contacts) - Only show if searching
    //    Map them to temporary ChatModels for display consistency
    final activeChatIds = allChats.map((e) => e.id).toSet();

    final filteredContacts = _isSearching.value
        ? allUsers
              .where((user) {
                final nameMatch = user.name.toLowerCase().contains(query);
                final isNotActive = !activeChatIds.contains(user.id);
                return nameMatch && isNotActive;
              })
              .map((user) {
                // Create a temporary ChatModel for the contact
                return ChatModel(
                  id: user.id,
                  name: user.name,
                  lastMessage: ChatMessageModel(
                    content: "Tap to message",
                    from: _chatCtrl.state.user!.id,
                    to: "",
                    timestamp: DateTime.now(),
                    type: MessageMediaType.text,
                  ),
                  time: DateTime.now(),
                  isOnline: user.isOnline,
                  participantIds: [user.id],
                );
              })
              .toList()
        : <ChatModel>[];

    // 4. Combine Lists
    final displayList = [...filteredChats, ...filteredContacts];

    if (displayList.isEmpty) {
      return Center(
        child: Text(
          _isSearching.value ? "No results found" : "No recent chats",
          style: const TextStyle(color: ChatColors.textLight),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(top: 10),
      itemCount: displayList.length,
      separatorBuilder: (ctx, i) => const Divider(height: 1, indent: 80),
      itemBuilder: (context, index) {
        final chat = displayList[index];
        return ChatPreviewTile(
          chat: chat,
          onTap: () {
            // Set selected chat in controller
            _chatCtrl.selectedChat = chat;

            if (chat.id == '1' || chat.name == "AI Assistant") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AiChatBase()),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => MessagesScreen(chat: chat)),
              );
            }
          },
        );
      },
    );
  }
}
