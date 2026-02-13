import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iconsax/iconsax.dart';

import '../../domain/enums/app_enums.dart';
import '../../domain/models/location_model.dart';
import '../../domain/models/user_model.dart';
import '../../domain/repos/auth_repository.dart';
import '../../domain/repos/user_repository.dart';
import '../../domain/repos/wallet_repository.dart';
import '../screens/authentication/login_screen.dart';
import '../screens/navigation/vipeep_navigation.dart';
import '../widgets/simple_alert_dialog.dart';

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

  // Storage keys (keep consistent)
  static const String _kLoggedIn = 'user_logged_in';
  static const String _kUid = 'user_uid';

  /// Call this from Splash / initial screen:
  /// If user is already logged in, go to home.
  Future<void> handleStartupRouting() async {
    // Trust Firebase first; storage is only a helper.
    final firebaseUser = FirebaseAuth.instance.currentUser;

    final bool storedLoggedIn = _storage.read(_kLoggedIn) == true;
    final String? storedUid = _storage.read(_kUid);

    if (firebaseUser != null) {
      // session exists
      await _persistSession(firebaseUser.uid);
      Get.offAll(() => const VipeepNavigation());
      return;
    }

    // If storage says logged in but Firebase says no => clean it (prevents stuck states)
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

      // Create profile + wallet (if any fails, handle cleanly)
      await _userRepo.createUser(user);
      await _walletRepo.ensureWalletExists(uid);

      // Persist session (so app can go to home next time)
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
      } else {
        // extremely rare edge case
        await _persistSession(''); // or just skip
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

  /// Logout method
  Future<void> logout() async {
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
      barrierDismissible: true,
    );

    if (confirm != true) return;

    try {
      isLoading.value = true;

      // Prefer repo
      try {
        await _authRepo.signOut();
      } catch (_) {
        // fallback if repo doesn't have signOut yet
        await FirebaseAuth.instance.signOut();
      }

      await _clearSession();

      //Navigate to login
       Get.offAll(() => const VipeepLoginScreen());
    } catch (e) {
      Get.snackbar(
        "Logout Failed",
        "Please try again.",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
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
}