import 'package:flutter/material.dart';
import 'package:utilities/utils/buttons.dart';

class LiveScreen extends StatelessWidget {
  const LiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Live")),
      body: Column(
        children: [
          AppButtons.expandedButton(text: "Video Call", onPressed: () {}),
          AppButtons.expandedButton(text: "Video Stream", onPressed: () {}),
        ],
      ),
    );
  }
}
