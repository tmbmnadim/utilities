import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:utilities/api/view/api_page.dart';
import 'package:utilities/artificial_intelligence/presentation/view/ai_base.dart';
import 'package:utilities/google_map/view/map_page.dart';
import 'package:utilities/google_ml_kit/view/ml_kit_screen.dart';
import 'package:utilities/live_communication/view/live_setup_screen.dart';
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
            text: "AI Chat",
            onPressed: () {
              Get.to(AiChatBase());
            },
          ),
          AppButtons.expandedButton(
            text: "Live Video",
            onPressed: () {
              Get.to(LiveSetupScreen());
            },
          ),
        ],
      ),
      // body: PageView(
      //   physics: NeverScrollableScrollPhysics(),
      //   controller: homeCtrl.pageController,
      //   children: homeCtrl.pages,
      // ),
      // bottomNavigationBar: BottomNavigationBar(
      //   currentIndex: homeCtrl.currentIndex,
      //   type: BottomNavigationBarType.fixed,
      //   backgroundColor: Theme.of(context).colorScheme.primary,
      //   selectedItemColor: Theme.of(context).colorScheme.onPrimary,
      //   unselectedItemColor: Theme.of(context).colorScheme.primaryFixedDim,
      //   onTap: (value) {
      //     if (!permissionCtrl.location.isGranted && value == 1) {
      //       permissionCtrl.getLocationPermissions();
      //       EasyLoading.showError("Location Permission is required!");
      //       return;
      //     }
      //     homeCtrl.animateToPage(value);
      //   },
      //   items: [
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.home_filled),
      //       label: "API",
      //     ),
      //     BottomNavigationBarItem(icon: Icon(Icons.map), label: "Map"),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.computer),
      //       label: "ML Kit",
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.chat_rounded),
      //       label: "Chat AI",
      //     ),
      //   ],
      // ),
    );
  }
}
