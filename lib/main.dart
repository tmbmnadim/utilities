import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import './home/home.dart';

void main() {
  runApp(UtilitiesApp());
}

class UtilitiesApp extends StatelessWidget {
  const UtilitiesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Utilities App",
      builder: EasyLoading.init(),
      home: Home(),
    );
  }
}
