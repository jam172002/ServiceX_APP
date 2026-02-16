import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:servicex_client_app/presentation/controllers/auth_controller.dart';
import 'package:servicex_client_app/presentation/controllers/category_controller.dart';
import 'package:servicex_client_app/presentation/controllers/location_controller.dart';

import 'package:servicex_client_app/domain/repos/auth_repository.dart';
import 'package:servicex_client_app/domain/repos/user_repository.dart';
import 'package:servicex_client_app/domain/repos/wallet_repository.dart';
import 'package:servicex_client_app/presentation/controllers/x_search_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<XSearchController>(() => XSearchController(), fenix: true);
    Get.put(LocationController(), permanent: true);

    // Repos
    Get.lazyPut<AuthRepository>(() => AuthRepository(auth: FirebaseAuth.instance), fenix: true);
    Get.lazyPut<UserRepository>(() => UserRepository(db: FirebaseFirestore.instance), fenix: true);
    Get.lazyPut<WalletRepository>(() => WalletRepository(db: FirebaseFirestore.instance), fenix: true);
    Get.lazyPut<CategoryController>(() => CategoryController(), fenix: true);

    Get.put<AuthController>(
      AuthController(
        authRepo: Get.find<AuthRepository>(),
        userRepo: Get.find<UserRepository>(),
        walletRepo: Get.find<WalletRepository>(),
      ),
      permanent: true,
    );
  }
}