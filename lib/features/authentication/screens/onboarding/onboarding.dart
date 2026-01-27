import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:servicex_client_app/features/authentication/screens/onboarding/widgets/onboarding_arrow_button.dart';
import 'package:servicex_client_app/features/authentication/screens/onboarding/widgets/onboarding_dots.dart';
import 'package:servicex_client_app/features/authentication/screens/onboarding/widgets/onboarding_page.dart';
import 'package:servicex_client_app/features/authentication/screens/onboarding/widgets/onboarding_skip.dart';
import 'package:servicex_client_app/utils/constants/images.dart';

import '../../../../controllers/onboarding_controller.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnBoardingController());
    return Scaffold(
      body: Stack(
        children: [
          /// Horizontal scrollable pages
          PageView(
            controller: controller.pageController,
            onPageChanged: controller.updatePageIndicator,
            children: [
              OnBoardingPage(
                image: XImages.boarding01,
                title: 'Find Trusted Professionals',
                subtitle:
                    'Get instant access to verified service providers for all your home and personal needs.',
              ),
              OnBoardingPage(
                image: XImages.boarding02,
                title: 'Fast & Easy Booking',
                subtitle:
                    'Choose a service, pick a time, and book in just a few taps — simple and hassle-free.',
              ),
              OnBoardingPage(
                image: XImages.boarding03,
                title: 'Secure Payments & Reliable Service',
                subtitle:
                    'Pay safely within the app and enjoy high-quality service delivered by trained professionals.',
              ),
            ],
          ),

          /// Skip button
          const OnBoardingSkip(),

          /// Dot Navigation
          const OnBoardingDotNavigation(),

          /// Arrow Button
          const OnBoardingArrowButton(),
        ],
      ),
    );
  }
}
