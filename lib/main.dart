import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:utilities/controllers/location_controller.dart';
import 'package:utilities/controllers/permission_controller.dart';
import 'package:utilities/routes/routes.dart';

void main() {
  runApp(UtilitiesApp());
}

class UtilitiesApp extends StatelessWidget {
  const UtilitiesApp({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(PermissionController(), permanent: true);
    Get.put(LocationController(), permanent: true);
    return GetMaterialApp(
      title: "Utilities App",
      builder: EasyLoading.init(),
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
    );
  }
}
