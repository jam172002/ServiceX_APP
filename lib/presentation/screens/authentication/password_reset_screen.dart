import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:servicex_client_app/presentation/screens/authentication/login_screen.dart';
import 'package:servicex_client_app/presentation/widgets/simple_alert_dialog.dart';
import 'package:servicex_client_app/presentation/widgets/text_form_field.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final _formKey = GlobalKey<FormState>();

  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _resetPassword() {
    if (_formKey.currentState!.validate()) {
      // Show success dialog
      Get.dialog(
        SimpleDialogWidget(
          message: "Successfully created new password",
          icon: Iconsax.tick_circle,
          iconColor: Colors.green,
          buttonText: "Continue",
          onOk: () {
            Get.offAll(() => const VipeepLoginScreen());
          },
        ),
        barrierDismissible: false,
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
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Text(
                  'New Password',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: XColors.black,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Your new password must be different from\npreviously used passwords.',
                  style: TextStyle(fontSize: 12, color: XColors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 25),

                // Password Field
                XFormField(
                  controller: passwordController,
                  label: "Password",
                  hint: "Enter your new password",
                  prefixIcon: Iconsax.lock,
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter a password";
                    }
                    // Strict password: min 8 chars, upper, lower, number, special char
                    final pattern =
                        r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>]).{8,}$';
                    final regex = RegExp(pattern);
                    if (!regex.hasMatch(value)) {
                      return "Password must be at least 8 characters,\ninclude uppercase, lowercase, number & special character";
                    }
                    return null;
                  },
                  cursorColor: XColors.success,
                ),
                const SizedBox(height: 10),

                // Confirm Password Field
                XFormField(
                  controller: confirmPasswordController,
                  label: "Confirm Password",
                  hint: "Confirm your password",
                  isPassword: true,
                  prefixIcon: Iconsax.password_check,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please confirm your password";
                    }
                    if (value != passwordController.text) {
                      return "Passwords do not match";
                    }
                    return null;
                  },
                  cursorColor: XColors.success,
                ),
                const SizedBox(height: 40),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _resetPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: XColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Create Password",
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
