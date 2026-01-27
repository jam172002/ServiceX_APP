import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../common/widgets/dialogs/simple_alert_dialog.dart';
import '../data/repos/auth_repository.dart';
import '../data/repos/user_repository.dart';
import '../data/repos/wallet_repository.dart';
import '../domain/enums/app_enums.dart';
import '../domain/models/location_model.dart';
import '../domain/models/user_model.dart';
import '../features/service/screens/navigation/vipeep_navigation.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepo;
  final UserRepository _userRepo;
  final WalletRepository _walletRepo;

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

  Future<void> logout() => _authRepo.signOut();
}
