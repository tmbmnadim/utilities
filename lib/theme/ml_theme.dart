import 'package:flutter/material.dart';

class ChatColors {
  static const Color primary = Color(0xFF00796B); // Teal 700
  static const Color primaryLight = Color(0xFFB2DFDB); // Teal 100
  static const Color background = Color(0xFFF5F7FB); // Light Grey-Blue
  static const Color surface = Colors.white;
  static const Color textDark = Color(0xFF263238); // Blue Grey 900
  static const Color textLight = Color(0xFF78909C); // Blue Grey 400
  static const Color myMessageBubble = Color(0xFF00796B);
  static const Color otherMessageBubble = Colors.white;
  static const Color error = Color(0xFFE57373);
}

class MLTheme {
  static final ThemeData mlKitTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF4285F4), // Google Blue
      primary: const Color(0xFF4285F4), // Google Blue
      secondary: const Color(0xFF34A853), // Google Green
      tertiary: const Color(0xFFFBBC04), // Google Yellow
      error: const Color(0xFFEA4335), // Google Red
      surface: const Color(0xFFF8F9FA),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: const Color(0xFF202124),
    ),
    scaffoldBackgroundColor: const Color(0xFFF8F9FA),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF4285F4),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: Colors.white,
        letterSpacing: 0.15,
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4285F4),
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        color: Color(0xFF202124),
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        color: Color(0xFF202124),
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        color: Color(0xFF202124),
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Color(0xFF5F6368),
      ),
    ),
    iconTheme: const IconThemeData(color: Color(0xFF5F6368)),
  );
}
