import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iconsax/iconsax.dart';
import '../common/widgets/dialogs/simple_alert_dialog.dart';
import '../data/repos/auth_repository.dart';
import '../data/repos/user_repository.dart';
import '../data/repos/wallet_repository.dart';
import '../domain/enums/app_enums.dart';
import '../domain/models/location_model.dart';
import '../domain/models/user_model.dart';
import '../features/authentication/screens/onboarding/account_type_selection.dart';
import '../features/service/screens/navigation/vipeep_navigation.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepo;
  final UserRepository _userRepo;
  final WalletRepository _walletRepo;

  final _storage = GetStorage();

  AuthController({
    required AuthRepository authRepo,
    required UserRepository userRepo,
    required WalletRepository walletRepo,
  })  : _authRepo = authRepo,
        _userRepo = userRepo,
        _walletRepo = walletRepo;

  final RxBool isLoading = false.obs;

  Future<UserModel> signUpUser({
    required AppRole role,
    required String name,
    required String email,
    required String phone,
    required Gender gender,
    required String password,
    required LocationModel location,
    String photoUrl = '',
  }) async {
    try {
      isLoading.value = true;

      final cred = await _authRepo.signUpWithEmailPassword(
        email: email,
        password: password,
      );

      final uid = cred.user!.uid;

      final user = UserModel(
        id: uid,
        role: role,
        name: name.trim(),
        email: email.trim(),
        phone: phone.trim(),
        gender: gender,
        location: location,
        photoUrl: photoUrl,
        isVerified: false,
        createdAt: DateTime.now(),
      );

      await _userRepo.createUser(user);
      await _walletRepo.ensureWalletExists(uid);

      return user;
    } finally {
      isLoading.value = false;
    }
  }



  Future<void> login({required String email, required String password}) async {
    try {
      isLoading.value = true;

      // You can use emailOrPhone as email for now, or add phone login in backend
      await _authRepo.signInWithEmailPassword(email: email, password: password);

      // Navigate after successful login
      Get.offAll(() => const VipeepNavigation());
    } catch (e) {
      Get.dialog(SimpleDialogWidget(
        icon: Iconsax.danger,
        iconColor: Colors.red,
        message: e.toString(),
      ));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendPasswordReset({required String email}) async {
    await _authRepo.sendPasswordResetEmail(email: email);
  }

  /// Logout method
  Future<void> logout() async {
    final confirm = await Get.defaultDialog<bool>(
      title: "Logout",
      middleText: "Are you sure you want to logout?",
      textConfirm: "Yes",
      textCancel: "No",
      onConfirm: () => Get.back(result: true),
      onCancel: () => Get.back(result: false),
    );

    if (confirm != true) return;

    try {
      isLoading.value = true;

      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();

      // Clear stored session/onboarding flags if any
      _storage.remove('user_logged_in');
      // Optional: reset onboarding if you want
      // _storage.remove('onboarding_done');

      // Navigate to Account Selection or Login
      Get.offAll(() => const AccountTypeSelectionScreen());
    } catch (e) {
      Get.snackbar(
        "Logout Failed",
        e.toString(),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
