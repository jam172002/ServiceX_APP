import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:servicex_client_app/domain/enums/app_enums.dart';
import 'package:servicex_client_app/domain/repos/user_repository.dart';
import 'package:servicex_client_app/presentation/controllers/auth_controller.dart';

class UserProfileController extends GetxController {
  final UserRepository _userRepo;
  final FirebaseAuth _auth;

  UserProfileController({
    UserRepository? userRepo,
    FirebaseAuth? auth,
  })  : _userRepo = userRepo ?? UserRepository(),
        _auth = auth ?? FirebaseAuth.instance;

  // ── State ─────────────────────────────────────────────────────────────────
  final RxBool isSaving = false.obs;
  final Rxn<File> pickedImage = Rxn<File>();

  // ── Booking stats ─────────────────────────────────────────────────────────
  final RxInt newCount = 0.obs;
  final RxInt activeCount = 0.obs;
  final RxInt completedCount = 0.obs;
  final RxInt cancelledCount = 0.obs;
  final RxBool statsLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBookingStats();
  }

  // ── Fetch booking stats ───────────────────────────────────────────────────
  Future<void> fetchBookingStats() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    try {
      statsLoading.value = true;
      final stats = await _userRepo.getBookingStats(uid);
      newCount.value = stats['new'] ?? 0;
      activeCount.value = stats['active'] ?? 0;
      completedCount.value = stats['completed'] ?? 0;
      cancelledCount.value = stats['cancelled'] ?? 0;
    } catch (_) {
    } finally {
      statsLoading.value = false;
    }
  }

  // ── Pick profile photo ────────────────────────────────────────────────────
  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 80,
    );
    if (picked != null) {
      pickedImage.value = File(picked.path);
    }
  }

  void clearPickedImage() => pickedImage.value = null;

  // ── Save profile ──────────────────────────────────────────────────────────
  Future<bool> saveProfile({
    required String name,
    required String phone,
    required Gender gender,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;

    try {
      isSaving.value = true;

      String photoUrl =
          Get.find<AuthController>().currentUser.value?.photoUrl ?? '';

      // Upload new photo if picked
      if (pickedImage.value != null) {
        photoUrl = await _userRepo.uploadProfilePhoto(
          uid: uid,
          file: pickedImage.value!,
        );
      }

      final updates = <String, dynamic>{
        'name': name.trim(),
        'phone': phone.trim(),
        'gender': enumToString(gender), // matches UserModel.toJson() serialization
        'photoUrl': photoUrl,
      };

      await _userRepo.updateUser(uid, updates);

      // Refresh AuthController's currentUser so all UI updates reactively
      await Get.find<AuthController>().loadCurrentUser();

      pickedImage.value = null;
      return true;
    } catch (e) {
      // Re-throw so the UI can show the actual error if needed
      return false;
    } finally {
      isSaving.value = false;
    }
  }
}