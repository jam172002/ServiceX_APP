import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../domain/enums/app_enums.dart';
import '../../../../domain/models/job_request_model.dart';
import '../../../../domain/models/service_category.dart';
import '../../../../domain/models/service_subcategory.dart';
import '../../../../domain/repos/job_repository.dart';
import '../../../../domain/repos/service_catalog_repo.dart';
import '../../../controllers/location_controller.dart';

class CreateJobController extends GetxController {
  // ── Dependencies ──────────────────────────────────────────────
  final ServiceCatalogRepo _catalogRepo = ServiceCatalogRepo(FirebaseFirestore.instance);
  final JobRepository _jobRepo = JobRepository();
  final LocationController locationController = Get.find<LocationController>();

  // ── Categories / Subcategories ────────────────────────────────
  final RxList<ServiceCategory> categories = <ServiceCategory>[].obs;
  final RxList<ServiceSubcategory> subcategories = <ServiceSubcategory>[].obs;
  final RxBool categoriesLoading = true.obs;
  final RxBool subcategoriesLoading = false.obs;
  final RxString categoriesError = ''.obs;

  final Rx<ServiceCategory?> selectedCategory = Rx<ServiceCategory?>(null);
  final Rx<ServiceSubcategory?> selectedSubcategory = Rx<ServiceSubcategory?>(null);

  StreamSubscription<List<ServiceCategory>>? _categorySub;

  // ── Form fields ───────────────────────────────────────────────
  final TextEditingController detailsController = TextEditingController();
  final TextEditingController minController = TextEditingController();
  final TextEditingController maxController = TextEditingController();

  final Rx<RangeValues> budgetRange = const RangeValues(50, 150).obs;
  // String — matches JobRequestModel.paymentMethod type
  final RxString selectedPayment = 'card'.obs;
  final Rx<DateTime?> selectedDate = Rx<DateTime?>(null);
  final Rx<TimeOfDay?> selectedTime = Rx<TimeOfDay?>(null);
  final RxList<File> pickedImages = <File>[].obs;

  // ── Submission state ──────────────────────────────────────────
  final RxBool isSubmitting = false.obs;

  final ImagePicker _picker = ImagePicker();

  // ── Optional SP pre-selection ─────────────────────────────────
  String? preselectedSpType;
  String? preselectedProviderId;

  // ─────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    minController.text = budgetRange.value.start.round().toString();
    maxController.text = budgetRange.value.end.round().toString();
    _listenCategories();
  }

  @override
  void onClose() {
    _categorySub?.cancel();
    detailsController.dispose();
    minController.dispose();
    maxController.dispose();
    super.onClose();
  }

  // ── Category stream ───────────────────────────────────────────
  void _listenCategories() {
    categoriesLoading.value = true;
    categoriesError.value = '';

    _categorySub?.cancel();
    _categorySub = _catalogRepo.watchCategories().listen(
          (data) {
        categories.assignAll(data);
        categoriesLoading.value = false;

        if (preselectedSpType != null && selectedCategory.value == null) {
          final match = data.firstWhereOrNull(
                (c) => c.name.toLowerCase() == preselectedSpType!.toLowerCase(),
          );
          if (match != null) selectCategory(match);
        }
      },
      onError: (e) {
        categoriesError.value = e.toString();
        categoriesLoading.value = false;
      },
    );
  }

  // ── Category / subcategory selection ─────────────────────────
  Future<void> selectCategory(ServiceCategory category) async {
    if (selectedCategory.value?.id == category.id) return;
    selectedCategory.value = category;
    selectedSubcategory.value = null;
    subcategories.clear();

    subcategoriesLoading.value = true;
    try {
      final subs = await _catalogRepo.getSubcategories(category.id);
      subcategories.assignAll(subs);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load subcategories: $e');
    } finally {
      subcategoriesLoading.value = false;
    }
  }

  void selectSubcategory(ServiceSubcategory sub) =>
      selectedSubcategory.value = sub;

  // ── Budget ────────────────────────────────────────────────────
  void updateBudgetRange(RangeValues values) {
    budgetRange.value = values;
    minController.text = values.start.round().toString();
    maxController.text = values.end.round().toString();
  }

  void onMinChanged(String val) {
    final parsed = double.tryParse(val);
    if (parsed != null && parsed >= 0 && parsed <= budgetRange.value.end) {
      budgetRange.value = RangeValues(parsed, budgetRange.value.end);
    }
  }

  void onMaxChanged(String val) {
    final parsed = double.tryParse(val);
    if (parsed != null && parsed >= budgetRange.value.start && parsed <= 10000) {
      budgetRange.value = RangeValues(budgetRange.value.start, parsed);
    }
  }

  // ── Image picker ──────────────────────────────────────────────
  Future<void> pickImages() async {
    try {
      final files = await _picker.pickMultiImage(imageQuality: 75);
      pickedImages.addAll(files.map((x) => File(x.path)));
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick images: $e');
    }
  }

  Future<void> pickImageFromCamera() async {
    try {
      final file = await _picker.pickImage(
          source: ImageSource.camera, imageQuality: 75);
      if (file != null) pickedImages.add(File(file.path));
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e');
    }
  }

  void removeImage(int index) => pickedImages.removeAt(index);

  // ── Validation ────────────────────────────────────────────────
  String? validate() {
    if (selectedCategory.value == null) return 'Please select a service type';
    if (selectedSubcategory.value == null) return 'Please select a sub-type';
    if (selectedDate.value == null || selectedTime.value == null) {
      return 'Please select date and time';
    }
    if (detailsController.text.trim().isEmpty) return 'Please add details';
    if (selectedPayment.value.isEmpty) return 'Please select a payment method';
    return null;
  }

  // ── Upload images to Firebase Storage ────────────────────────
  Future<List<String>> _uploadImages(String jobId) async {
    if (pickedImages.isEmpty) return [];
    final urls = <String>[];
    for (int i = 0; i < pickedImages.length; i++) {
      final ref = FirebaseStorage.instance
          .ref('job_images/$jobId/image_$i.jpg');
      await ref.putFile(pickedImages[i]);
      urls.add(await ref.getDownloadURL());
    }
    return urls;
  }

  // ── Create job in Firestore ───────────────────────────────────
  Future<String?> createJob({
    required bool forAll,
    VoidCallback? onSuccess,
  }) async {
    if (isSubmitting.value) return null;
    isSubmitting.value = true;

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      final now = DateTime.now();

      // Reserve a doc ID upfront so images are nested under it
      final docRef = FirebaseFirestore.instance
          .collection('job_requests')
          .doc();
      final jobId = docRef.id;

      // Upload images, get download URLs
      final imageUrls = await _uploadImages(jobId);

      // Merge date + time into scheduledAt
      final scheduledAt = DateTime(
        selectedDate.value!.year,
        selectedDate.value!.month,
        selectedDate.value!.day,
        selectedTime.value!.hour,
        selectedTime.value!.minute,
      );

      final loc = locationController.currentLocation.value;

      final job = JobRequestModel(
        id: jobId,
        userId: userId,
        providerId: forAll ? null : preselectedProviderId,
        // ── Category / subcategory — both ID and name stored ─────
        categoryId: selectedCategory.value!.id,
        categoryName: selectedCategory.value!.name,
        subcategoryId: selectedSubcategory.value!.id,
        subcategoryName: selectedSubcategory.value!.name,
        // ── Details ───────────────────────────────────────────────
        details: detailsController.text.trim(),
        // ── Location flat fields (model has address/lat/lng) ──────
        address: loc?.address ?? '',
        lat: loc?.lat ?? 0.0,
        lng: loc?.lng ?? 0.0,
        // ── Schedule ──────────────────────────────────────────────
        scheduledAt: scheduledAt,
        // ── Budget as int (model uses int) ────────────────────────
        budgetMin: budgetRange.value.start.round(),
        budgetMax: budgetRange.value.end.round(),
        // ── Payment as String (model uses String) ─────────────────
        paymentMethod: selectedPayment.value,
        imageUrls: imageUrls,
        isOpenForAll: forAll,
        status: JobStatus.pending,
        createdAt: now,
        updatedAt: now,
      );

      await _jobRepo.createJob(job);
      onSuccess?.call();
      return jobId;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create job: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    } finally {
      isSubmitting.value = false;
    }
  }

  // ── Payload for ConfirmationDialog (display only) ─────────────
  Map<String, dynamic> buildDisplayPayload(
      BuildContext context, {
        required bool forAll,
      }) {
    return {
      'categoryName': selectedCategory.value!.name,
      'subcategoryName': selectedSubcategory.value?.name,
      'details': detailsController.text.trim(),
      'location': locationController.currentLocation.value?.address ?? '',
      'date': selectedDate.value!.toIso8601String(),
      'time': selectedTime.value!.format(context),
      'budgetMin': budgetRange.value.start.round(),
      'budgetMax': budgetRange.value.end.round(),
      'payment': selectedPayment.value, // String — no conversion needed
      'images': List<File>.from(pickedImages),
      'forAll': forAll,
    };
  }
}