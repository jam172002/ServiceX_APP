import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:servicex_client_app/features/authentication/screens/onboarding/account_type_selection.dart';

class OnBoardingController extends GetxController {
  static OnBoardingController get instance => Get.find();

  final storage = GetStorage();

  // Page Controller
  final pageController = PageController();

  // Current page index
  Rx<int> currentPageIndex = 0.obs;

  // Total number of onboarding pages
  final int totalPages = 3;

  // Update page index when scrolling
  void updatePageIndicator(int index) {
    currentPageIndex.value = index;
  }

  // Jump to selected dot page
  void dotNavigationClick(int index) {
    currentPageIndex.value = index;
    pageController.jumpToPage(index);
  }

  // Computed property to check if last page
  bool get isLastPage => currentPageIndex.value == totalPages - 1;

  // Go to next page
  Future<void> nextPage() async {
    if (isLastPage) {
      // Mark onboarding done
     await storage.write('onboarding_done', true);
      Get.offAll(() => const AccountTypeSelectionScreen());
    } else {
      int page = currentPageIndex.value + 1;
      pageController.jumpToPage(page);
    }
  }

  // Skip to the last page
  Future<void> skipPage() async {
    await storage.write('onboarding_done', true);
    Get.offAll(() => const AccountTypeSelectionScreen());
  }
}
