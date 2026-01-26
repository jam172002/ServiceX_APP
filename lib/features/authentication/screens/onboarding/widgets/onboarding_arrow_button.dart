import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:servicex_client_app/features/authentication/controllers/onboarding/onboarding_controller.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';
import 'package:servicex_client_app/utils/constants/sizes.dart';
import 'package:servicex_client_app/utils/device/device_utils.dart';

class OnBoardingArrowButton extends StatelessWidget {
  const OnBoardingArrowButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: XSizes.defaultSpace,
      bottom: XDeviceUtils.getBottomNavigationBarHeight() - 25,
      child: ElevatedButton(
        onPressed: () => OnBoardingController.instance.nextPage(),
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          backgroundColor: XColors.primary,
        ),
        child: const Icon(Iconsax.arrow_right_3),
      ),
    );
  }
}
