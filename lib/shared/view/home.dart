import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:utilities/api/view/api_page.dart';
import 'package:utilities/artificial_intelligence/presentation/view/ai_base.dart';
import 'package:utilities/communication/controllers/chat_controller.dart';
import 'package:utilities/communication/view/chat_setup.dart';
import 'package:utilities/google_map/view/map_page.dart';
import 'package:utilities/google_ml_kit/view/ml_kit_screen.dart';
import 'package:utilities/communication/view/chat_screen.dart';
import 'package:utilities/shared/controller/home_controller.dart';
import 'package:utilities/shared/controller/permission_controller.dart';
import 'package:utilities/utils/buttons.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final homeCtrl = Get.find<HomeController>();
  final permissionCtrl = Get.find<PermissionController>();

  @override
  void initState() {
    super.initState();
    permissionCtrl.getLocationPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("List of Features")),
      body: Column(
        children: [
          AppButtons.expandedButton(
            text: "API Testing",
            onPressed: () {
              Get.to(ApiScreen());
            },
          ),
          AppButtons.expandedButton(
            text: "ML Kit",
            onPressed: () {
              Get.to(MLKitScreen());
            },
          ),
          AppButtons.expandedButton(
            text: "Map Screen",
            onPressed: () {
              if (!permissionCtrl.location.isGranted) {
                permissionCtrl.getLocationPermissions();
                EasyLoading.showError("Location Permission is required!");
                return;
              }
              Get.to(MapScreen());
            },
          ),
          AppButtons.expandedButton(
            text: "Chat",
            onPressed: () {
              Get.to(ChatSetupScreen());
            },
          ),
        ],
      ),
    );
  }
}
