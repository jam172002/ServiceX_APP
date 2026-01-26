import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:servicex_client_app/app.dart';
import 'package:servicex_client_app/features/authentication/controllers/location/vipeep_location_controller.dart';

void main() {
  Get.put(LocationController());
  runApp(const MyApp());
}
