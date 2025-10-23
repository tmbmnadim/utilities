import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:utilities/api/view/api_page.dart';
import 'package:utilities/artificial_intelligence/presentation/view/ai_base.dart';
import 'package:utilities/artificial_intelligence/presentation/view/artificial_intelligence.dart';
import 'package:utilities/google_map/view/map_page.dart';
import 'package:utilities/google_ml_kit/view/ml_kit_screen.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(HomeController());
  }
}

class HomeController extends GetxController {
  PageController pageController = PageController();

  // final List<Widget> _pages = [ApiScreen(), MapScreen(), MLKitScreen()];
  final Map<String, Widget> _pages = {
    "Game API": ApiScreen(),
    "Map": MapScreen(),
    "ML Kit": MLKitScreen(),
    "AI Chat": AiChatBase(),
  };

  List<String> get titles => _pages.keys.toList();
  String get title => _pages.keys.toList()[currentIndex];
  List<Widget> get pages => _pages.values.toList();

  final RxInt _currentIndex = 0.obs;
  int get currentIndex => _currentIndex.value;

  void animateToPage(int index) {
    _currentIndex.value = index;
    pageController.animateToPage(
      index,
      duration: Durations.medium1,
      curve: Curves.linear,
    );
  }
}
