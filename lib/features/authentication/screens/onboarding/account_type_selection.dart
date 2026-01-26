import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:servicex_client_app/features/authentication/screens/login/fixxer_login_screen.dart';
import 'package:servicex_client_app/features/authentication/screens/login/vipeep_login.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';
import 'package:servicex_client_app/utils/constants/images.dart';
import 'package:servicex_client_app/utils/helpers/helper_functions.dart';

class AccountTypeSelectionScreen extends StatelessWidget {
  const AccountTypeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = XHelperFunctions.screenHeight();
    final screenWidth = XHelperFunctions.screenWidth();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top stack with circles and logo
            Expanded(
              flex: 4,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer circle
                  Container(
                    width: screenWidth * 0.8,
                    height: screenWidth * 0.8,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(
                        color: XColors.borderColor.withValues(alpha: 0.2),
                        width: 3,
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                  // Inner circle
                  Container(
                    width: screenWidth * 0.5,
                    height: screenWidth * 0.5,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(
                        color: XColors.borderColor.withValues(alpha: 0.2),
                        width: 3,
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                  // App logo
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: screenWidth * 0.7,
                        child: Image.asset(XImages.appLogo),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Get it done. Anytime, Anywhere.',
                        style: TextStyle(
                          fontSize: screenHeight * 0.018,
                          color: XColors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Bottom content: account selection
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 28,
                      ),
                      decoration: BoxDecoration(
                        // color: XColors.secondaryBG,
                        // borderRadius: BorderRadius.circular(12),
                        // border: Border.all(color: XColors.borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // VIPEEPS Button
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Looking for services?',
                                style: TextStyle(
                                  color: XColors.black,
                                  fontSize: screenHeight * 0.016,
                                ),
                              ),
                              const SizedBox(height: 6),
                              OutlinedButton.icon(
                                onPressed: () =>
                                    Get.to(() => const VipeepLoginScreen()),
                                icon: const Icon(Iconsax.user),
                                label: const Text('VIPEEPS'),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: Size.fromHeight(
                                    screenHeight * 0.065,
                                  ),
                                  padding: EdgeInsets.zero,
                                  alignment: Alignment.center,
                                  side: const BorderSide(
                                    color: XColors.borderColor,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // FIXXERS Button
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Offering services?',
                                style: TextStyle(
                                  color: XColors.black,
                                  fontSize: screenHeight * 0.016,
                                ),
                              ),
                              const SizedBox(height: 6),
                              OutlinedButton.icon(
                                onPressed: () {
                                  Get.to(() => FixxerLoginScreen());
                                },
                                icon: const Icon(Iconsax.briefcase),
                                label: const Text('FIXXERS'),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: Size.fromHeight(
                                    screenHeight * 0.065,
                                  ),
                                  padding: EdgeInsets.zero,
                                  alignment: Alignment.center,
                                  side: const BorderSide(
                                    color: XColors.borderColor,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
