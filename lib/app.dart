import 'package:flutter/material.dart';
import 'package:utilities/google_map/controllers/location_controller.dart';
import 'package:utilities/shared/controller/permission_controller.dart';
import 'package:utilities/theme/ml_theme.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import '/routes/routes.dart';
import 'routes/route_list.dart';

class UtilitiesApp extends StatelessWidget {
  const UtilitiesApp({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(PermissionController(), permanent: true);
    Get.put(LocationController(), permanent: true);
    return GetMaterialApp(
      title: "Utilities App",
      theme: MLTheme.mlKitTheme,
      builder: EasyLoading.init(),
      initialRoute: Routes.home,
      getPages: AppRoutes.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}
