import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../authentication/login_screen.dart';
import '../navigation/vipeep_navigation.dart';
import '../onboarding/onboarding.dart';

class SplashRouter extends StatefulWidget {
  const SplashRouter({super.key});

  @override
  State<SplashRouter> createState() => _SplashRouterState();
}

class _SplashRouterState extends State<SplashRouter> {
  final _storage = GetStorage();

  static const String kOnboardingDone = 'onboarding_done';
  static const String kLoggedIn = 'user_logged_in'; // same as AuthController

  @override
  void initState() {
    super.initState();
    Future.microtask(_route);
  }

  Future<void> _route() async {
    final box = GetStorage();

    const kOnboardingDone = 'onboarding_done';

    // ✅ Wait for auth restore
    final user = await FirebaseAuth.instance.authStateChanges().first;

    if (user != null) {
      Get.offAll(() => const VipeepNavigation());
      return;
    }

    final onboardingDone = box.read(kOnboardingDone) == true;

    if (onboardingDone) {
      Get.offAll(() => const VipeepLoginScreen());
      return;
    }

    Get.offAll(() => const OnBoardingScreen());
  }

  @override
  Widget build(BuildContext context) {
    // Simple splash (no design change needed)
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}