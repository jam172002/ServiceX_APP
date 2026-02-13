import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:servicex_client_app/presentation/controllers/onboarding_controller.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';
import 'package:servicex_client_app/utils/constants/sizes.dart';
import 'package:servicex_client_app/utils/device/device_utils.dart';

class OnBoardingSkip extends StatelessWidget {
  const OnBoardingSkip({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: XDeviceUtils.getAppBarHeight(),
      right: XSizes.defaultSpace,
      child: TextButton(
        onPressed: () async {
          HapticFeedback.selectionClick(); // optional, feels premium
          await OnBoardingController.instance.skipPage();
        },
        style: TextButton.styleFrom(
          splashFactory: NoSplash.splashFactory,
          overlayColor: Colors.transparent,
          foregroundColor: XColors.black,
        ),
        child: const Text('Skip'),
      ),
    );
  }
}