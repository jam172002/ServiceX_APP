import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:servicex_client_app/app.dart';
import 'package:servicex_client_app/app_bindings.dart';
import 'package:servicex_client_app/presentation/screens/splash/splash_router.dart';
import 'package:servicex_client_app/services/chat_notification_service.dart';

import 'data_seeder/app_data_seeder.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Init push notification service (permissions + local channel + FCM listeners)
  await ChatNotificationService.instance.init();

  AppBindings().dependencies();
  await FirebaseSeed.seedAll();
  runApp(const MyApp(initialScreen: SplashRouter()));
}