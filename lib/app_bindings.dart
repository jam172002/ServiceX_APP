import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';

import 'package:servicex_client_app/domain/repos/auth_repository.dart';
import 'package:servicex_client_app/domain/repos/user_repository.dart';
import 'package:servicex_client_app/domain/repos/wallet_repository.dart';
import 'package:servicex_client_app/presentation/screens/authentication/controller/auth_controller.dart';
import 'package:servicex_client_app/presentation/screens/categories_n_subcategories/controller/category_controller.dart';
import 'package:servicex_client_app/presentation/controllers/location_controller.dart';
import 'package:servicex_client_app/presentation/controllers/x_search_controller.dart';
import 'package:servicex_client_app/presentation/screens/profile/controller/user_profile_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<XSearchController>(() => XSearchController(), fenix: true);
    Get.put(LocationController(), permanent: true);

    // ── Repos ──────────────────────────────────────────────────────────────
    Get.lazyPut<AuthRepository>(
          () => AuthRepository(auth: FirebaseAuth.instance),
      fenix: true,
    );
    Get.lazyPut<UserRepository>(
          () => UserRepository(
        db: FirebaseFirestore.instance,
        storage: FirebaseStorage.instance,
      ),
      fenix: true,
    );
    Get.lazyPut<WalletRepository>(
          () => WalletRepository(db: FirebaseFirestore.instance),
      fenix: true,
    );

    // ── Controllers ────────────────────────────────────────────────────────
    Get.lazyPut<CategoryController>(() => CategoryController(), fenix: true);

    Get.lazyPut<UserProfileController>(
          () => UserProfileController(
        userRepo: Get.find<UserRepository>(),
      ),
      fenix: true,
    );

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