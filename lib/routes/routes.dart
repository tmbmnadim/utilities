// /c:/Users/mansu/Documents/Projects/flutter_utils/utilities/lib/routes/routes.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:utilities/controllers/home_controller.dart';
import 'package:utilities/view/home.dart';
import 'package:utilities/view/homepage.dart';
import 'package:utilities/view/map_page.dart';

/// Simple GetX routes setup with example pages and binding.
/// Replace placeholder pages/controllers with real implementations.

class Routes {
  static const String home = '/';
  static const String homepage = '/homepage';
  static const String mapPage = '/map';
}

class AppPages {
  static const String initial = Routes.home;

  // register all pages here
  static final List<GetPage<dynamic>> routes = [
    GetPage(
      name: Routes.home,
      page: () => const Home(),
      binding: HomeBinding(),
    ),
    GetPage(name: Routes.homepage, page: () => Homepage()),
    GetPage(name: Routes.mapPage, page: () => MapPage()),
  ];
}
