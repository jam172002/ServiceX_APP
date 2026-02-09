import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:servicex_client_app/presentation/screens/onboarding/onboarding.dart';
import 'package:servicex_client_app/utils/theme/theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      theme: XAppTheme.lightTheme,
      darkTheme: XAppTheme.darkTheme,
      home: OnBoardingScreen(),
    );
  }
}
