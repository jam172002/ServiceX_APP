import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iconsax/iconsax.dart';
import 'package:servicex_client_app/presentation/controllers/location_controller.dart';

import '../../../../domain/enums/app_enums.dart';
import '../../../../domain/models/location_model.dart';
import '../../../../domain/models/user_model.dart';
import '../../../../domain/repos/auth_repository.dart';
import '../../../../domain/repos/user_repository.dart';
import '../../../../domain/repos/wallet_repository.dart';
import '../login_screen.dart';
import '../../navigation/vipeep_navigation.dart';
import '../../../widgets/simple_alert_dialog.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepo;
  final UserRepository _userRepo;
  final WalletRepository _walletRepo;

  final _storage = GetStorage();
  final Rxn<UserModel> currentUser = Rxn<UserModel>();

  AuthController({
    required AuthRepository authRepo,
    required UserRepository userRepo,
    required WalletRepository walletRepo,
  })  : _authRepo = authRepo,
        _userRepo = userRepo,
        _walletRepo = walletRepo;

  final RxBool isLoading = false.obs;

  static const String _kLoggedIn = 'user_logged_in';
  static const String _kUid = 'user_uid';

  Future<void> handleStartupRouting() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;

    final bool storedLoggedIn = _storage.read(_kLoggedIn) == true;
    final String? storedUid = _storage.read(_kUid);

    if (firebaseUser != null) {
      await _persistSession(firebaseUser.uid);
      await loadCurrentUser();

      final u = currentUser.value;
      if (u != null) {
        await _syncLocationFromProfile(u);
      }

      Get.offAll(() => const VipeepNavigation());
      return;
    }

    if (storedLoggedIn || storedUid != null) {
      await _clearSession();
    }
  }

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
        email: email.trim(),
        password: password,
      );

      final firebaseUser = cred.user;
      if (firebaseUser == null) {
        throw FirebaseAuthException(
          code: 'null-user',
          message: 'Signup failed. Please try again.',
        );
      }

      final uid = firebaseUser.uid;

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

      currentUser.value = user;

      await _syncLocationFromProfile(user);
      await _persistSession(uid);
      return user;
    } on FirebaseAuthException catch (e) {
      _showErrorDialog(_mapFirebaseAuthError(e));
      rethrow;
    } catch (e) {
      _showErrorDialog('Something went wrong. Please try again.');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _syncLocationFromProfile(UserModel user) async {
    final profileLoc = user.location;
    if (profileLoc == null) return;
    if (profileLoc.address.trim().isEmpty) return;
    if (!Get.isRegistered<LocationController>()) return;

    final locationController = Get.find<LocationController>();
    await locationController.addLocation(profileLoc.copyWith(isDefault: true));
  }

  Future<void> login({required String email, required String password}) async {
    try {
      isLoading.value = true;

      await _authRepo.signInWithEmailPassword(
        email: email.trim(),
        password: password,
      );

      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await _persistSession(uid);
        await loadCurrentUser();

        final u = currentUser.value;
        if (u != null) {
          await _syncLocationFromProfile(u);
        }
      } else {
        await _persistSession('');
      }

      Get.offAll(() => const VipeepNavigation());
    } on FirebaseAuthException catch (e) {
      _showErrorDialog(_mapFirebaseAuthError(e));
    } catch (e) {
      _showErrorDialog('Login failed. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendPasswordReset({required String email}) async {
    try {
      await _authRepo.sendPasswordResetEmail(email: email.trim());
      Get.snackbar(
        "Email Sent",
        "Password reset email has been sent.",
        snackPosition: SnackPosition.BOTTOM,
      );
    } on FirebaseAuthException catch (e) {
      _showErrorDialog(_mapFirebaseAuthError(e));
    } catch (e) {
      _showErrorDialog('Unable to send reset email. Try again.');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // LOGOUT — FIXED
  // Fixes applied:
  //   1. Dialog result was never awaited properly when tapping outside
  //      (barrierDismissible: true returns null, not false — handled now).
  //   2. isLoading was set AFTER the await dialog, causing UI glitches if
  //      the user tapped quickly.
  //   3. currentUser was cleared AFTER navigation, causing reactive widgets
  //      to briefly re-render stale data on the login screen.
  //   4. LocationController.clearAll() was called inside the try block after
  //      navigation, which could throw and swallow the nav call silently.
  //   5. No fallback if Get.offAll throws (e.g. route not found).
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    // ── Step 1: Show confirmation dialog ────────────────────────────────────
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text("Yes"),
          ),
        ],
      ),
      // FIX 1: barrierDismissible: true means tapping outside returns null.
      // Treat null the same as false — do not proceed.
      barrierDismissible: false,
    );

    // FIX 1 (cont): guard against null (tap-outside) as well as explicit false
    if (confirm != true) return;

    // ── Step 2: Show loading immediately ────────────────────────────────────
    // FIX 2: set loading before any async work so the UI reacts instantly
    isLoading.value = true;

    try {
      // ── Step 3: Sign out from Firebase ──────────────────────────────────
      try {
        await _authRepo.signOut();
      } catch (_) {
        // Fallback: force Firebase sign-out even if repo fails
        await FirebaseAuth.instance.signOut();
      }

      // ── Step 4: Clear local state BEFORE navigation ──────────────────────
      // FIX 3: clear currentUser first so Obx widgets on the upcoming
      // login screen don't receive stale user data during the transition.
      currentUser.value = null;

      // ── Step 5: Clear storage ────────────────────────────────────────────
      await _clearSession();

      // ── Step 6: Clear location controller safely ─────────────────────────
      // FIX 4: moved BEFORE Get.offAll so any errors here don't silently
      // swallow the navigation call.
      if (Get.isRegistered<LocationController>()) {
        try {
          await Get.find<LocationController>().clearAll();
        } catch (_) {
          // Non-fatal — continue with logout even if this fails
        }
      }

      // ── Step 7: Navigate to login ────────────────────────────────────────
      // FIX 5: use offAllNamed if you have named routes, or wrap in try/catch.
      // offAll with a builder is the safest option here.
      Get.offAll(
            () => const VipeepLoginScreen(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 300),
      );
    } catch (e) {
      // ── If anything fails, reset loading and show error ──────────────────
      Get.snackbar(
        "Logout Failed",
        "Please try again.",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      // FIX: always reset loading regardless of success or failure
      isLoading.value = false;
    }
  }

  Future<void> _persistSession(String uid) async {
    await _storage.write(_kLoggedIn, true);
    if (uid.isNotEmpty) {
      await _storage.write(_kUid, uid);
    }
  }

  Future<void> _clearSession() async {
    await _storage.remove(_kLoggedIn);
    await _storage.remove(_kUid);
  }

  void _showErrorDialog(String message) {
    Get.dialog(
      SimpleDialogWidget(
        icon: Iconsax.danger,
        iconColor: Colors.red,
        message: message,
      ),
    );
  }

  String _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect email or password.';
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Password is too weak. Try a stronger password.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }

  Future<void> loadCurrentUser() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      currentUser.value = null;
      return;
    }

    try {
      final user = await _userRepo.getUserById(uid);
      currentUser.value = user;
    } catch (_) {
      currentUser.value = null;
    }
  }
}