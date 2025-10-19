import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:utilities/view/homepage.dart';
import 'package:utilities/view/map_page.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(HomeController());
  }
}

class HomeController extends GetxController {
  PageController pageController = PageController();

  final List<Widget> _pages = [Homepage(), MapPage()];

  List<Widget> get pages => _pages;

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
