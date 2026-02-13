import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:servicex_client_app/app.dart';
import 'package:servicex_client_app/app_bindings.dart';
import 'package:servicex_client_app/presentation/screens/splash/splash_router.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  AppBindings().dependencies();

  runApp(const MyApp(initialScreen: SplashRouter()));
}