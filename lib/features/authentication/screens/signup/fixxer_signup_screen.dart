import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:servicex_client_app/common/widgets/dialogs/simple_alert_dialog.dart';
import 'package:servicex_client_app/common/widgets/fields/text_form_field.dart';
import 'package:servicex_client_app/features/authentication/screens/location/location_selector_screen.dart';
import 'package:servicex_client_app/features/authentication/screens/login/fixxer_login_screen.dart';
import 'package:servicex_client_app/features/authentication/screens/permissions/permission_screen.dart';
import 'package:servicex_client_app/features/authentication/screens/signup/fixxers_profile_data_gathering_screen.dart';
import 'package:servicex_client_app/features/authentication/screens/signup/widgets/select_gender.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';
import 'package:servicex_client_app/utils/constants/images.dart';

class FixxerSignupScreen extends StatefulWidget {
  const FixxerSignupScreen({super.key});

  @override
  State<FixxerSignupScreen> createState() => _FixxerSignupScreenState();
}

class _FixxerSignupScreenState extends State<FixxerSignupScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  String? selectedGender;
  String? selectedLocation;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _signup() {
    if (_formKey.currentState!.validate()) {
      if (selectedGender == null) {
        Get.dialog(
          SimpleDialogWidget(
            icon: Iconsax.danger,
            iconColor: XColors.warning,
            message: "Please select your gender",
          ),
        );
        return;
      }

      if (selectedLocation == null) {
        Get.dialog(
          SimpleDialogWidget(
            icon: Iconsax.danger,
            iconColor: XColors.warning,
            message: "Please select your location",
          ),
        );
        return;
      }

      Get.dialog(
        SimpleDialogWidget(
          message: "Fixxer account created successfully!",
          icon: Iconsax.tick_circle,
          iconColor: Colors.green,
          buttonText: "Continue",
          onOk: () {
            Get.off(() => FixxersProfileDataGatheringScreen());
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final spacing = screenHeight < 700 ? 6.0 : 8.0;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              /// Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 10),

                        /// Title
                        Text(
                          'Create Fixxer Account',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: XColors.black,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Join Fixxer and start receiving\nservice requests today.',
                          style: TextStyle(fontSize: 12, color: XColors.grey),
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(height: spacing),

                        /// Name
                        XFormField(
                          controller: nameController,
                          label: 'Full Name',
                          hint: 'Enter your name',
                          prefixIcon: Iconsax.user,
                          cursorColor: XColors.success,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Name is required";
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: spacing),

                        /// Email
                        XFormField(
                          controller: emailController,
                          label: 'Email',
                          hint: 'Enter your email address',
                          prefixIcon: Iconsax.sms,
                          cursorColor: XColors.success,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Email is required";
                            }
                            if (!RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            ).hasMatch(value)) {
                              return "Enter a valid email";
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: spacing),

                        /// Phone
                        XFormField(
                          controller: phoneController,
                          label: 'Phone',
                          hint: 'Enter your phone number',
                          prefixIcon: Iconsax.call,
                          keyboardType: TextInputType.phone,
                          cursorColor: XColors.success,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Phone number is required";
                            }
                            if (!RegExp(r'^\+?\d{10,15}$').hasMatch(value)) {
                              return "Enter a valid phone number";
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: spacing),

                        /// Password
                        XFormField(
                          controller: passwordController,
                          label: 'Password',
                          hint: 'Create a strong password',
                          prefixIcon: Iconsax.password_check,
                          isPassword: true,
                          cursorColor: XColors.success,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Password is required";
                            }
                            if (!RegExp(
                              r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{6,}$',
                            ).hasMatch(value)) {
                              return "Password must contain upper, lower, number & special character";
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: spacing),

                        /// Gender
                        GenderDropdown(
                          onChanged: (val) {
                            setState(() {
                              selectedGender = val;
                            });
                          },
                        ),

                        SizedBox(height: spacing),

                        /// Location
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () {
                              setState(() {
                                selectedLocation = "Selected location";
                              });

                              Get.to(
                                () => PermissionScreen(
                                  title: 'Need Location Access',
                                  subtitle:
                                      'Please allow location access to show nearby jobs.',
                                  illustration: Image.asset(
                                    XImages.getLocation,
                                  ),
                                  allowButtonText: 'Allow',
                                  showDenyButton: true,
                                  onDeny: () {},
                                  onAllow: () {
                                    Get.to(
                                      () => const LocationSelectorScreen(),
                                    );
                                  },
                                ),
                              );
                            },
                            icon: const Icon(
                              Iconsax.location,
                              size: 16,
                              color: XColors.primary,
                            ),
                            label: const Text(
                              'Select your service area',
                              style: TextStyle(
                                fontSize: 12,
                                color: XColors.primary,
                              ),
                            ),
                            style: ButtonStyle(
                              padding: WidgetStateProperty.all(EdgeInsets.zero),
                              minimumSize: WidgetStateProperty.all(Size.zero),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              overlayColor: WidgetStateProperty.all(
                                Colors.transparent,
                              ),
                              alignment: Alignment.centerRight,
                            ),
                          ),
                        ),

                        SizedBox(height: spacing),

                        /// Signup Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _signup,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: XColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              "Sign up as Fixxer",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 4),

                        /// Terms
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 4,
                          children: [
                            Text(
                              'By signing up, you agree to our',
                              style: TextStyle(
                                fontSize: 10,
                                color: XColors.grey,
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
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
                                'Terms & Conditions',
                                style: TextStyle(fontSize: 10),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 25),

                        /// Social
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
                              'or Sign up with',
                              style: TextStyle(
                                fontSize: 10,
                                color: XColors.grey,
                              ),
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

              /// Bottom Login
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 4,
                  children: [
                    Text(
                      'Already a Fixxer?',
                      style: TextStyle(fontSize: 12, color: XColors.grey),
                    ),
                    TextButton(
                      onPressed: () => Get.to(() => const FixxerLoginScreen()),
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
                        'Login',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
