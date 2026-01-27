import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';
import 'package:servicex_client_app/utils/constants/sizes.dart';
import 'package:servicex_client_app/utils/device/device_utils.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../../controllers/onboarding_controller.dart';
import '../account_type_selection.dart';

class OnBoardingArrowButton extends StatelessWidget {
  const OnBoardingArrowButton({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = GetStorage();

    return Positioned(
      right: XSizes.defaultSpace,
      bottom: XDeviceUtils.getBottomNavigationBarHeight() - 25,
      child: ElevatedButton(
        onPressed: () async {
          final controller = OnBoardingController.instance;

          if (controller.isLastPage) {
            // Mark onboarding done
            await  storage.write('onboarding_done', true);
            Get.offAll(() => const AccountTypeSelectionScreen());
          } else {
            controller.nextPage();
          }
        },
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          backgroundColor: XColors.primary,
        ),
        child: const Icon(Iconsax.arrow_right_3),
      ),
    );
  }
}
