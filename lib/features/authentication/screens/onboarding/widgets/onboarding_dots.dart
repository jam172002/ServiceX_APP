import 'package:flutter/material.dart';
import 'package:servicex_client_app/features/authentication/controllers/onboarding/onboarding_controller.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';
import 'package:servicex_client_app/utils/constants/sizes.dart';
import 'package:servicex_client_app/utils/device/device_utils.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoardingDotNavigation extends StatelessWidget {
  const OnBoardingDotNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = OnBoardingController.instance;

    return Positioned(
      bottom: XDeviceUtils.getBottomNavigationBarHeight(),
      left: XSizes.defaultSpace,
      child: SmoothPageIndicator(
        controller: controller.pageController,
        onDotClicked: controller.dotNavigationClick,
        count: 3,
        effect: ExpandingDotsEffect(activeDotColor: XColors.grey, dotHeight: 6),
      ),
    );
  }
}
