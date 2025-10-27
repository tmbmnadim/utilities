import 'package:flutter/material.dart';

class AppButtons {
  static Widget expandedButton({
    required String text,
    required VoidCallback onPressed,
    bool isLoading = false,
  }) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: onPressed,
            child: Row(
              spacing: 10,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isLoading)
                  SizedBox.square(
                    dimension: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 1.5,
                    ),
                  ),
                Text(text),

                if (isLoading) SizedBox.square(dimension: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
