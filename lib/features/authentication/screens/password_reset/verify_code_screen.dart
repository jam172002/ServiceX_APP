import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pinput/pinput.dart';
import 'package:servicex_client_app/common/widgets/dialogs/simple_alert_dialog.dart';
import 'package:servicex_client_app/features/authentication/screens/password_reset/password_reset_screen.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

class VerifyCodeScreen extends StatefulWidget {
  const VerifyCodeScreen({super.key, required this.isServiceProvider});
  final bool isServiceProvider;
  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final TextEditingController otpController = TextEditingController();

  void _confirmCode() {
    if (otpController.text.length != 4) {
      Get.dialog(
        SimpleDialogWidget(
          icon: Iconsax.danger,
          iconColor: XColors.warning,
          message: "Please enter the 4 digits verification code.",
        ),
      );
      return;
    }

    // Navigate to Reset Password Screen
    Get.to(
      () => PasswordResetScreen(isServiceProvider: widget.isServiceProvider),
    );
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 55,
      height: 55,
      textStyle: const TextStyle(
        fontSize: 18,
        color: Colors.black87,
        fontWeight: FontWeight.w500,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Iconsax.arrow_left_24, color: XColors.black, size: 25),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          padding: EdgeInsets.zero,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Text(
                'Verify Code',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: XColors.black,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Please enter the code we just sent to this email:',
                style: TextStyle(fontSize: 12, color: XColors.grey),
                textAlign: TextAlign.center,
              ),
              Text(
                'iammsufyan@gmail.com',
                style: TextStyle(fontSize: 12, color: XColors.primary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25),

              // OTP Field
              Pinput(
                length: 4,
                controller: otpController,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: defaultPinTheme.copyWith(
                  decoration: defaultPinTheme.decoration!.copyWith(
                    border: Border.all(color: XColors.primary),
                  ),
                ),
                showCursor: true,
              ),

              const SizedBox(height: 40),

              // Confirm Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _confirmCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: XColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Confirm",
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
