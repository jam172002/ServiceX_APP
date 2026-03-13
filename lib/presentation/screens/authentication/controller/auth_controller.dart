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
import '../../../../services/chat_notification_service.dart';
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

      // ✅ FIX: was `firebaseUser as String` — must be firebaseUser.uid
      await ChatNotificationService.instance.saveTokenForClient(firebaseUser.uid);

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

        // ✅ FIX: save FCM token on every fresh login
        await ChatNotificationService.instance.saveTokenForClient(uid);

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
      barrierDismissible: false,
    );

    if (confirm != true) return;

    isLoading.value = true;

    try {
      try {
        await _authRepo.signOut();
      } catch (_) {
        await FirebaseAuth.instance.signOut();
      }

      currentUser.value = null;

      await _clearSession();

      if (Get.isRegistered<LocationController>()) {
        try {
          await Get.find<LocationController>().clearAll();
        } catch (_) {}
      }

      Get.offAll(
            () => const VipeepLoginScreen(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 300),
      );
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