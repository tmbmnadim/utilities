import 'package:get/get.dart';
import 'package:utilities/artificial_intelligence/presentation/view/artificial_intelligence.dart';
import 'package:utilities/shared/controller/home_controller.dart';
import 'package:utilities/shared/view/home.dart';
import 'package:utilities/google_map/view/map_page.dart';
import 'package:utilities/google_ml_kit/view/ml_kit_screen.dart';
import 'package:utilities/landing.dart';

import 'route_list.dart';

class AppRoutes {
  static final String initial = Routes.initial;
  static final List<GetPage<dynamic>> routes = [
    GetPage(name: Routes.initial, page: () => const LandingPage()),
    GetPage(
      name: Routes.home,
      page: () => const Home(),
      binding: HomeBinding(),
    ),
    GetPage(name: Routes.mapPage, page: () => MapScreen()),
    GetPage(
      name: Routes.mlKitPage,
      page: () => MLKitScreen(),
    ),
    GetPage(name: Routes.aiChat, page: () => AiChatScreen()),
  ];
}
