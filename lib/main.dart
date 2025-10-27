import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:utilities/artificial_intelligence/ai_injection_container.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final envFile = await _getEnvFile();
  await dotenv.load(fileName: envFile);
  initAI();
  runApp(UtilitiesApp());
}

Future<String> _getEnvFile() async {
  // Check for mobile (iOS or Android)
  if (Platform.isIOS) {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    if (iosInfo.isPhysicalDevice) {
      return "assets/phone.env";
    } else {
      return "assets/emulator.env";
    }
  } else if (Platform.isAndroid) {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    if (androidInfo.isPhysicalDevice) {
      return "assets/phone.env";
    } else {
      return "assets/emulator.env";
    }
  }

  // Return a default .env file for other platforms or in case of an error.
  return "assets/emulator.env";
}
