import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class OnboardingController extends GetxController {
  static OnboardingController get instance => Get.find();

  //Variables
  final pageController = PageController();
  Rx<int> currentPageIndex = 0.obs;

  //update curent page index when page scrolled
  void updatePageIndicator(index) => currentPageIndex.value = index;

  ///update current page index when dot navigation clicked
  void dotNavigationClick(index) {
    currentPageIndex.value = index;
    pageController.jumpTo(index);
  }

  ///jump to next page
  void nextPage() {
    if (currentPageIndex.value == 2) {
      Get.offNamed('/login');
    } else {
      int page = currentPageIndex.value + 1;
      pageController.jumpToPage(page);
    }
  }

  ///update current page index when skip button clicked
  void skipPage() {
    currentPageIndex.value = 2;
    pageController.jumpTo(2);
  }
}
