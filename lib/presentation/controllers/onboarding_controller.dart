import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../screens/authentication/login_screen.dart';

class OnBoardingController extends GetxController {
  static OnBoardingController get instance => Get.find();

  final storage = GetStorage();

  // Keys (keep consistent across app)
  static const String kOnboardingDone = 'onboarding_done';

  // Page Controller
  final pageController = PageController();

  // Current page index
  final RxInt currentPageIndex = 0.obs;

  // Total number of onboarding pages
  final int totalPages = 3;

  // Update page index when scrolling
  void updatePageIndicator(int index) {
    currentPageIndex.value = index;
  }

  // Jump to selected dot page
  Future<void> dotNavigationClick(int index) async {
    currentPageIndex.value = index;
    await pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  // Computed property to check if last page
  bool get isLastPage => currentPageIndex.value == totalPages - 1;

  // Go to next page
  Future<void> nextPage() async {
    if (isLastPage) {
      await _completeOnboarding();
      return;
    }

    final next = currentPageIndex.value + 1;
    await pageController.animateToPage(
      next,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  // Skip onboarding (mark done + go login)
  Future<void> skipPage() async {
    await _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    await storage.write(kOnboardingDone, true);
    // After onboarding done -> go to login
    Get.offAll(() => const VipeepLoginScreen());
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}