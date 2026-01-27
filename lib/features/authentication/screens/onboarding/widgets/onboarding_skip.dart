import 'package:flutter/material.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';
import 'package:servicex_client_app/utils/constants/sizes.dart';
import 'package:servicex_client_app/utils/device/device_utils.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../account_type_selection.dart';

class OnBoardingSkip extends StatelessWidget {
  const OnBoardingSkip({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = GetStorage();

    return Positioned(
      top: XDeviceUtils.getAppBarHeight(),
      right: XSizes.defaultSpace,
      child: TextButton(
        onPressed: () async {
          // Mark onboarding done
         await storage.write('onboarding_done', true);
          Get.offAll(() => const AccountTypeSelectionScreen());
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
