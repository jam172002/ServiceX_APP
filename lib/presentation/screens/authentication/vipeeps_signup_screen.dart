import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:servicex_client_app/presentation/screens/authentication/login_screen.dart';
import 'package:servicex_client_app/presentation/widgets/simple_alert_dialog.dart';
import 'package:servicex_client_app/presentation/widgets/text_form_field.dart';
import 'package:servicex_client_app/presentation/screens/location/location_selector_screen.dart';
import 'package:servicex_client_app/presentation/screens/authentication/permission_screen.dart';
import 'package:servicex_client_app/presentation/widgets/select_gender.dart';
import 'package:servicex_client_app/presentation/screens/navigation/vipeep_navigation.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';
import 'package:servicex_client_app/utils/constants/images.dart';
import '../../../../domain/enums/app_enums.dart';
import '../../../../domain/models/location_model.dart';
import '../../controllers/auth_controller.dart';

class VipeepSignupScreen extends StatefulWidget {
  const VipeepSignupScreen({super.key});

  @override
  State<VipeepSignupScreen> createState() => _VipeepSignupScreenState();
}

class _VipeepSignupScreenState extends State<VipeepSignupScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final authController = Get.find<AuthController>();
  LocationModel? selectedLocation;



  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  String? selectedGender;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _signup() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedGender == null) {
      Get.dialog(SimpleDialogWidget(
        icon: Iconsax.danger,
        iconColor: XColors.warning,
        message: "Please select your gender",
      ));
      return;
    }

    if (selectedLocation == null) {
      Get.dialog(SimpleDialogWidget(
        icon: Iconsax.danger,
        iconColor: XColors.warning,
        message: "Please select your location",
      ));
      return;
    }

    // Convert selectedGender string to Gender enum safely
    final genderValue = Gender.values.firstWhere(
          (e) => e.name.toLowerCase() == selectedGender!.toLowerCase(),
      orElse: () => Gender.other,
    );

    try {
      await authController.signUpUser(
        role: AppRole.user,
        name: nameController.text,
        email: emailController.text,
        phone: phoneController.text,
        gender: genderValue,
        password: passwordController.text,
        location: selectedLocation!,
      );

      Get.offAll(() => const VipeepNavigation());
    } catch (e) {
      Get.dialog(SimpleDialogWidget(
        icon: Iconsax.danger,
        iconColor: XColors.error,
        message: e.toString(),
      ));
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
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 10),
                        Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: XColors.black,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Tell us a bit about yourself or register\nwith your social account.',
                          style: TextStyle(fontSize: 12, color: XColors.grey),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: spacing),

                        // Name
                        XFormField(
                          controller: nameController,
                          label: 'User Name',
                          hint: 'Enter your name',
                          cursorColor: XColors.success,
                          prefixIcon: Iconsax.user,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Name is required";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: spacing),

                        // Email
                        XFormField(
                          controller: emailController,
                          label: 'Email',
                          hint: 'Enter your email address',
                          cursorColor: XColors.success,
                          prefixIcon: Iconsax.sms,
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

                        // Phone
                        XFormField(
                          controller: phoneController,
                          label: 'Phone',
                          hint: 'Enter your phone number',
                          cursorColor: XColors.success,
                          prefixIcon: Iconsax.call,
                          keyboardType: TextInputType.phone,
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

                        // Password
                        XFormField(
                          controller: passwordController,
                          label: 'Password',
                          hint: 'Enter your password',
                          cursorColor: XColors.success,
                          prefixIcon: Iconsax.password_check,
                          isPassword: true,
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

                        // Gender
                        GenderDropdown(
                          onChanged: (val) {
                            setState(() {
                              selectedGender = val;
                            });
                          },
                        ),
                        SizedBox(height: spacing),

                        // Location
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () async {
                              final allowed = await Get.to<bool>(
                                    () => PermissionScreen(
                                  title: 'Need Location Access',
                                  subtitle: 'Please give us access to your GPS Location',
                                  illustration: Image.asset(XImages.getLocation),
                                  allowButtonText: 'Allow',
                                  showDenyButton: true,
                                  onAllow: () => Get.back(result: true),
                                  onDeny: () => Get.back(result: false),
                                ),
                              );

                              if (allowed != true) return;

                              final location = await Get.to<LocationModel>(
                                    () => const LocationSelectorScreen(),
                              );

                              if (location != null) {
                                setState(() => selectedLocation = location);
                              }
                            },


                            icon: const Icon(
                              Iconsax.location,
                              size: 16,
                              color: XColors.primary,
                            ),
                            label: const Text(
                              'Select your location',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
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
                        if (selectedLocation != null) ...[
                          const SizedBox(height: 6),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: XColors.grey,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              selectedLocation!.address,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],

                        SizedBox(height: spacing),

                        // Signup Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _signup,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: XColors.primary,

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                             child: Obx(() => ElevatedButton(
                              onPressed: authController.isLoading.value ? null : _signup,
                              child: authController.isLoading.value
                                  ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                                  : const Text("Sign up"),
                            )),

                          ),
                        ),
                        SizedBox(height: 4),

                        // Terms & Social
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 4,
                          children: [
                            Text(
                              'By signing up, You agree to our',
                              style: TextStyle(
                                color: XColors.grey,
                                fontSize: 10,
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
                              child: Text(
                                'Terms & Conditions',
                                style: TextStyle(
                                  color: XColors.primary,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 25),

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
                              style: TextStyle(
                                color: XColors.grey,
                                fontSize: 10,
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
                        SizedBox(height: 25),

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
                        SizedBox(height: spacing),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom Login link
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 4,
                  children: [
                    Text(
                      'Already have an account?',
                      style: TextStyle(color: XColors.grey, fontSize: 12),
                    ),
                    TextButton(
                      onPressed: () => Get.to(() => VipeepLoginScreen()),
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
                        'Login',
                        style: TextStyle(color: XColors.primary, fontSize: 12),
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
