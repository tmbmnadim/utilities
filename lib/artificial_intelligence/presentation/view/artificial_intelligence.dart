import 'package:flutter/material.dart';

import '../../data/models/chat_message_model.dart';
import '../../domain/entities/chat_message.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<AiChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();

  bool _isInitializing = true;
  bool _hasError = false;
  bool _isSending = false;
  bool _isAITyping = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      // Simulate initialization (loading models, connecting to service, etc.)
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() {
          _isInitializing = false;
          _hasError = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _hasError = true;
        });
      }
    }
  }

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty || _isSending) return;

    final messageText = _controller.text;
    _controller.clear();

    setState(() {
      _isSending = true;
      _messages.add(
        ChatMessage(
          id: "0",
          content: messageText,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
    });

    _scrollToBottom();

    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _isSending = false;
      _isAITyping = true;
    });

    _scrollToBottom();

    // Simulate AI response delay
    await Future.delayed(const Duration(milliseconds: 1500));

    if (mounted) {
      setState(() {
        _isAITyping = false;
        _messages.add(
          ChatMessage(
            id: "0",
            content: _getAIResponse(messageText),
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
      _scrollToBottom();
    }
  }

  String _getAIResponse(String message) {
    if (message.toLowerCase().contains('hello') ||
        message.toLowerCase().contains('hi')) {
      return 'Hello! How can I help you today?';
    } else if (message.toLowerCase().contains('how are you')) {
      return 'I\'m doing well, thank you for asking! How can I assist you?';
    }
    return 'I understand your message. This is a demo AI response. In a real app, this would connect to an AI service.';
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return _buildLoadingScreen();
    }

    if (_hasError) {
      return _buildErrorScreen();
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'AI Assistant',
              style: TextStyle(
                color: Color(0xFF2D3748),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty && !_isAITyping
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length + (_isAITyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length && _isAITyping) {
                        return _buildTypingIndicator();
                      }
                      return _buildMessageBubble(_messages[index]);
                    },
                  ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667EEA)),
            ),
            const SizedBox(height: 16),
            const Text(
              'Initializing AI Assistant...',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF718096),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: Color(0xFFEF4444),
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Failed to Initialize',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Unable to connect to the AI service. Please check your connection and try again.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFF718096)),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isInitializing = true;
                    _hasError = false;
                  });
                  _initialize();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF667EEA),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Retry',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.chat_bubble_outline,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Start a conversation',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Send a message to begin chatting',
            style: TextStyle(fontSize: 14, color: Color(0xFF718096)),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.smart_toy, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(13),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDot(0),
                const SizedBox(width: 4),
                _buildTypingDot(1),
                const SizedBox(width: 4),
                _buildTypingDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        final delay = index * 0.2;
        final animValue = (value - delay).clamp(0.0, 1.0);
        final scale = 0.6 + (0.4 * (1 - (animValue - 0.5).abs() * 2));

        return Transform.scale(
          scale: scale,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFF718096),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      },
      onEnd: () {
        if (mounted && _isAITyping) {
          setState(() {});
        }
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser ? const Color(0xFF667EEA) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(13),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  fontSize: 15,
                  color: message.isUser
                      ? Colors.white
                      : const Color(0xFF2D3748),
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.person,
                color: Color(0xFF4A5568),
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF7FAFC),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _controller,
                enabled: !_isSending,
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(color: Color(0xFFA0AEC0)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
                textInputAction: TextInputAction.send,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isSending
                    ? [
                        const Color(0xFF667EEA).withAlpha(179),
                        const Color(0xFF764BA2).withAlpha(179),
                      ]
                    : [const Color(0xFF667EEA), const Color(0xFF764BA2)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: IconButton(
              onPressed: _isSending ? null : _sendMessage,
              icon: _isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.send_rounded, color: Colors.white),
              padding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
