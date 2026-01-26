import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../data/repos/auth_repository.dart';
import '../data/repos/user_repository.dart';
import '../data/repos/wallet_repository.dart';
import '../domain/enums/app_enums.dart';
import '../domain/models/user_model.dart';

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

  final Rxn<User> firebaseUser = Rxn<User>();
  StreamSubscription<User?>? _sub;

  @override
  void onInit() {
    super.onInit();
    _sub = _authRepo.authStateChanges().listen((u) => firebaseUser.value = u);
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }

  User? get currentFirebaseUser => firebaseUser.value;

  Future<UserModel> signUpUser({
    required AppRole role,
    required String name,
    required String email,
    required String phone,
    required Gender gender,
    required String password,
    String photoUrl = '',
    bool isVerified = false,
    Map<String, dynamic>? locationJson,
  }) async {
    final cred = await _authRepo.signUpWithEmailPassword(email: email, password: password);
    final uid = cred.user!.uid;

    final user = UserModel(
      id: uid,
      role: role,
      name: name,
      email: email,
      phone: phone,
      gender: gender,
      location: locationJson == null ? null : (locationJson['label'] != null ? null : null),
      photoUrl: photoUrl,
      isVerified: isVerified,
      createdAt: DateTime.now(),
    );

    await _userRepo.createUser(user);
    await _walletRepo.ensureWalletExists(uid);

    if (role == AppRole.provider) {
      // Provider profile is handled in ProviderController via ProviderRepository
    }

    return user;
  }

  Future<void> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    await _authRepo.signInWithEmailPassword(email: email, password: password);
  }

  Future<void> sendPasswordReset({required String email}) async {
    await _authRepo.sendPasswordResetEmail(email: email);
  }

  Future<void> logout() => _authRepo.signOut();
}
