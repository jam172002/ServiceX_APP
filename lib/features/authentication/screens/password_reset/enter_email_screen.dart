import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:servicex_client_app/common/widgets/dialogs/simple_alert_dialog.dart';
import 'package:servicex_client_app/common/widgets/fields/text_form_field.dart';
import 'package:servicex_client_app/features/authentication/screens/password_reset/verify_code_screen.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

class EnterEmailScreen extends StatefulWidget {
  const EnterEmailScreen({super.key, required this.isServiceProvider});

  final bool isServiceProvider;

  @override
  State<EnterEmailScreen> createState() => _EnterEmailScreenState();
}

class _EnterEmailScreenState extends State<EnterEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  void _sendResetEmail() {
    if (_formKey.currentState!.validate()) {
      print("Reset email sent to: ${emailController.text}");

      // Show dialog and navigate when pressing OK
      Get.dialog(
        SimpleDialogWidget(
          message: "Password reset instructions have been sent to your email.",
          icon: Iconsax.tick_circle,
          iconColor: Colors.green,
          buttonText: "Continue",
          onOk: () {
            // Navigate to next screen
            Get.to(
              () =>
                  VerifyCodeScreen(isServiceProvider: widget.isServiceProvider),
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Text(
                  'Reset Password',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: XColors.black,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Enter email associated with your account and\nwe\'ll send an email with instructions to reset\nyour password.',
                  style: TextStyle(fontSize: 12, color: XColors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 25),

                // Email Field
                XFormField(
                  controller: emailController,
                  label: "Email",
                  hint: "Enter your email",
                  prefixIcon: Iconsax.sms,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter email";
                    }
                    if (!RegExp(
                      r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$",
                    ).hasMatch(value)) {
                      return "Enter a valid email";
                    }
                    return null;
                  },
                  cursorColor: XColors.success,
                ),
                const SizedBox(height: 40),

                // Send Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _sendResetEmail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: XColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Send",
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
