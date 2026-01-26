import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:servicex_client_app/common/widgets/fields/text_form_field.dart';
import 'package:servicex_client_app/features/authentication/screens/password_reset/enter_email_screen.dart';
import 'package:servicex_client_app/features/authentication/screens/signup/fixxer_signup_screen.dart';
import 'package:servicex_client_app/features/service/screens/navigation/fixxer_navigation.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';
import 'package:servicex_client_app/utils/constants/images.dart';

class FixxerLoginScreen extends StatefulWidget {
  const FixxerLoginScreen({super.key});

  @override
  State<FixxerLoginScreen> createState() => _FixxerLoginScreenState();
}

class _FixxerLoginScreenState extends State<FixxerLoginScreen> {
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

                      /// Title
                      Text(
                        'Fixxer Login',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: XColors.black,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Sign in to manage your jobs and services.',
                        style: TextStyle(fontSize: 12, color: XColors.grey),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: spacing),

                      /// Email / Phone
                      XFormField(
                        controller: emailPhoneController,
                        label: "Email or Phone",
                        hint: "Enter email or phone",
                        prefixIcon: Iconsax.sms,
                        keyboardType: TextInputType.text,
                        cursorColor: XColors.success,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter email or phone";
                          }

                          final phoneRegExp = RegExp(r'^\d{10,15}$');
                          final emailRegExp = RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          );

                          if (phoneRegExp.hasMatch(value) ||
                              emailRegExp.hasMatch(value)) {
                            return null;
                          }

                          return "Enter a valid email or phone number";
                        },
                      ),

                      SizedBox(height: spacing),

                      /// Password
                      XFormField(
                        controller: passwordController,
                        label: "Password",
                        hint: "Enter your password",
                        isPassword: true,
                        prefixIcon: Iconsax.lock,
                        cursorColor: XColors.success,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Password is required";
                          }
                          if (value.length < 6) {
                            return "Minimum 6 characters required";
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: spacing + 10),

                      /// Login Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              Get.to(() => const FixxerNavigation());
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

                      /// Forgot Password
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 4,
                        children: [
                          Text(
                            'Forgot password?',
                            style: TextStyle(color: XColors.grey, fontSize: 13),
                          ),
                          TextButton(
                            onPressed: () => Get.to(
                              () => const EnterEmailScreen(
                                isServiceProvider: true,
                              ),
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
                            child: const Text(
                              'Reset it',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 25),

                      /// Divider
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
                            'or login with',
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

                      const SizedBox(height: 25),

                      /// Social Login
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

            /// Bottom Signup
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 4,
                children: [
                  Text(
                    'New Fixxer?',
                    style: TextStyle(color: XColors.grey, fontSize: 13),
                  ),
                  TextButton(
                    onPressed: () => Get.to(() => const FixxerSignupScreen()),
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
                    child: const Text(
                      'Create account',
                      style: TextStyle(fontSize: 13),
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
