import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:utilities/communication/controllers/chat_controller.dart';
import 'package:utilities/communication/view/chat_screen.dart'; // Import ChatListScreen
import 'package:utilities/utils/buttons.dart';

class ChatSetupScreen extends StatefulWidget {
  const ChatSetupScreen({super.key});

  @override
  State<ChatSetupScreen> createState() => _ChatSetupScreenState();
}

class _ChatSetupScreenState extends State<ChatSetupScreen> {
  final _usernameCtrl = TextEditingController();
  final liveCtrl = Get.find<ChatController>();

  @override
  void initState() {
    super.initState();
    _checkPermissions();

    // Initialize connection silently so it is ready when user clicks "Enter"
    if (!liveCtrl.state.isConnectedToWS) {
      liveCtrl.connectWS();
    }
  }

  void _checkPermissions() async {
    // Requesting permissions early ensures seamless call experience later
    await [Permission.camera, Permission.microphone].request();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: GetBuilder<ChatController>(
            builder: (controller) {
              final isLoading =
                  controller.state.status == LiveSessionStatus.loading;

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Icon or Logo could go here
                  Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withAlpha(30),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.hub_outlined,
                      size: 40,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    "Join Server",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Enter a temporary username to connect to the live chat server.",
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Name Input
                  TextField(
                    controller: _usernameCtrl,
                    enabled: !isLoading,
                    decoration: InputDecoration(
                      labelText: "Display Name",
                      hintText: "e.g. John Doe",
                      prefixIcon: const Icon(Icons.person_outline_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _handleLogin(controller),
                  ),
                  const SizedBox(height: 24),

                  // Action Button
                  AppButtons.expandedButton(
                    text: "Start Messaging",
                    isLoading: isLoading,
                    onPressed: () => _handleLogin(controller),
                  ),

                  if (!controller.state.isConnectedToWS) ...[
                    const SizedBox(height: 16),
                    const Text(
                      "Connecting to server...",
                      style: TextStyle(fontSize: 12, color: Colors.orange),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _handleLogin(ChatController controller) {
    final name = _usernameCtrl.text.trim();
    if (name.isEmpty) {
      EasyLoading.showToast("Please enter a name");
      return;
    }

    if (!controller.state.isConnectedToWS) {
      EasyLoading.showError("Server not connected yet. Please wait.");
      return;
    }

    controller.createUser(
      name,
      onSuccess: () {
        // Navigate to the Chat List Screen upon success
        // Using Get.off to prevent back navigation to login
        Get.off(() => ChatListScreen());
      },
      onFailure: (e) {
        EasyLoading.showError(e);
      },
    );
  }
}
