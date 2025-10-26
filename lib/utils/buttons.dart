import 'package:flutter/material.dart';

class AppButtons {
  static Widget expandedButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(onPressed: onPressed, child: Text(text)),
        ),
      ],
    );
  }
}
