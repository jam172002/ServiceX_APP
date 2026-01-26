import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:servicex_client_app/common/widgets/fields/text_form_field.dart';
import 'package:servicex_client_app/features/authentication/screens/password_reset/enter_email_screen.dart';
import 'package:servicex_client_app/features/authentication/screens/signup/vipeeps_signup_screen.dart';
import 'package:servicex_client_app/features/service/screens/navigation/vipeep_navigation.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';
import 'package:servicex_client_app/utils/constants/images.dart';

class VipeepLoginScreen extends StatefulWidget {
  const VipeepLoginScreen({super.key});

  @override
  State<VipeepLoginScreen> createState() => _VipeepLoginScreenState();
}

class _VipeepLoginScreenState extends State<VipeepLoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final emailPhoneController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailPhoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final spacing = screenHeight < 700 ? 6.0 : 12.0;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        'Log In',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: XColors.black,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Continue by entering your details.',
                        style: TextStyle(fontSize: 12, color: XColors.grey),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: spacing),

                      // Email / Phone
                      XFormField(
                        controller: emailPhoneController,
                        label: "Email or Phone",
                        hint: "Enter email or phone",
                        prefixIcon: Iconsax.sms,
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter email or phone";
                          }

                          // Check if input is a phone number (digits only)
                          final phoneRegExp = RegExp(
                            r'^\d{10,15}$',
                          ); // 10-15 digits
                          // Check if input is a valid email
                          final emailRegExp = RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          );

                          if (phoneRegExp.hasMatch(value)) {
                            return null; // valid phone
                          } else if (emailRegExp.hasMatch(value)) {
                            return null; // valid email
                          } else {
                            return "Enter a valid email or phone number";
                          }
                        },
                        cursorColor: XColors.success,
                      ),
                      SizedBox(height: spacing),

                      // Password
                      XFormField(
                        controller: passwordController,
                        label: "Password",
                        hint: "Enter your password",
                        isPassword: true,
                        prefixIcon: Iconsax.lock,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Password is required";
                          }
                          if (value.length < 6) {
                            return "Minimum 6 characters required";
                          }
                          return null;
                        },
                        cursorColor: XColors.success,
                      ),

                      SizedBox(height: spacing + 10),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              Get.to(() => VipeepNavigation());
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: XColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Log In",
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(height: spacing),

                      // Forget Password
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 4,
                        children: [
                          Text(
                            'Forget Password?',
                            style: TextStyle(color: XColors.grey, fontSize: 13),
                          ),
                          TextButton(
                            onPressed: () => Get.to(
                              () => EnterEmailScreen(isServiceProvider: false),
                            ),
                            style:
                                TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  foregroundColor: XColors.primary,
                                ).copyWith(
                                  overlayColor: WidgetStateProperty.all(
                                    Colors.transparent,
                                  ),
                                ),
                            child: Text(
                              'Reset it',
                              style: TextStyle(
                                color: XColors.primary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 25),

                      // Or sign in with
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: XColors.borderColor,
                              thickness: 1,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'or Sign in with',
                            style: TextStyle(color: XColors.grey, fontSize: 11),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Divider(
                              color: XColors.borderColor,
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 25),

                      // Social Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {},
                            child: SizedBox(
                              height: 20,
                              child: Image.asset(XImages.googleLogo),
                            ),
                          ),
                          const SizedBox(width: 40),
                          GestureDetector(
                            onTap: () {},
                            child: SizedBox(
                              height: 20,
                              child: Image.asset(XImages.appleLogo),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Signup row
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 4,
                children: [
                  Text(
                    'Don\'t have an account?',
                    style: TextStyle(color: XColors.grey, fontSize: 13),
                  ),
                  TextButton(
                    onPressed: () => Get.to(() => VipeepSignupScreen()),
                    style:
                        TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          foregroundColor: XColors.primary,
                        ).copyWith(
                          overlayColor: WidgetStateProperty.all(
                            Colors.transparent,
                          ),
                        ),
                    child: Text(
                      'Signup',
                      style: TextStyle(color: XColors.primary, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
