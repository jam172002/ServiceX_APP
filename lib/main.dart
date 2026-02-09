import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:servicex_client_app/app.dart';
import 'package:servicex_client_app/presentation/controllers/vipeep_location_controller.dart';
import 'package:servicex_client_app/presentation/screens/onboarding/onboarding.dart';

void main() {
  Get.put(LocationController());
  runApp(const MyApp(initialScreen: OnBoardingScreen(),));
}
