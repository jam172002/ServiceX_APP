import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:servicex_client_app/app.dart';
import 'package:servicex_client_app/controllers/vipeep_location_controller.dart';
import 'controllers/auth_controller.dart';
import 'data/repos/auth_repository.dart';
import 'data/repos/user_repository.dart';
import 'data/repos/wallet_repository.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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

  runApp(const MyApp());
}

