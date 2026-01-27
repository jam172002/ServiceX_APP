import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:servicex_client_app/app.dart';
import 'package:servicex_client_app/controllers/vipeep_location_controller.dart';
import 'controllers/auth_controller.dart';
import 'data/repos/auth_repository.dart';
import 'data/repos/user_repository.dart';
import 'data/repos/wallet_repository.dart';
import 'features/authentication/screens/onboarding/account_type_selection.dart';
import 'features/authentication/screens/onboarding/onboarding.dart';
import 'features/service/screens/navigation/vipeep_navigation.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await GetStorage.init();
  final storage = GetStorage();

  final user = FirebaseAuth.instance.currentUser;
  final bool userLoggedIn = storage.read('user_logged_in') ?? false;
  final bool onboardingDone = storage.read('onboarding_done') ?? false;

  print("DEBUG: onboardingDone = $onboardingDone");
  print("DEBUG: userLoggedIn = $userLoggedIn");



  // Dependency injection AFTER Firebase init
  Get.put(LocationController());
  Get.put(AuthRepository());
  Get.put(UserRepository());
  Get.put(WalletRepository());

  Get.put(AuthController(
    authRepo: Get.find(),
    userRepo: Get.find(),
    walletRepo: Get.find(),
  ));

  Widget initialScreen;

// Decide initial screen


  if (!onboardingDone) {
    initialScreen = OnBoardingScreen();
  } else if (userLoggedIn) {
    initialScreen = const VipeepNavigation();
  } else {
    initialScreen = const AccountTypeSelectionScreen();
  }
  runApp(MyApp(initialScreen: initialScreen));
}

