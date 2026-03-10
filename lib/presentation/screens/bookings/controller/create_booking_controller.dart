import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../domain/enums/app_enums.dart';
import '../../../../domain/models/booking_model.dart';
import '../../../../domain/models/service_category.dart';
import '../../../../domain/models/service_subcategory.dart';
import '../../../../domain/repos/booking_repository.dart';
import '../../../../domain/repos/service_catalog_repo.dart';
import '../../../controllers/location_controller.dart';

class CreateBookingController extends GetxController {
  // ── Dependencies ──────────────────────────────────────────────
  final ServiceCatalogRepo _catalogRepo =
  ServiceCatalogRepo(FirebaseFirestore.instance);
  final BookingRepository _bookingRepo = BookingRepository();
  final LocationController locationController = Get.find<LocationController>();

  // ── Fixer (passed from previous screen) ──────────────────────
  // Set once from CreateBookingScreen.initState — never changes mid-session.
  late final String fixerId;
  late final String fixerName;
  late final String? fixerImageUrl;

  // ── Categories / Subcategories ────────────────────────────────
  final RxList<ServiceCategory> categories = <ServiceCategory>[].obs;
  final RxList<ServiceSubcategory> subcategories = <ServiceSubcategory>[].obs;
  final RxBool categoriesLoading = true.obs;
  final RxBool subcategoriesLoading = false.obs;
  final RxString categoriesError = ''.obs;

  final Rx<ServiceCategory?> selectedCategory = Rx<ServiceCategory?>(null);
  final Rx<ServiceSubcategory?> selectedSubcategory =
  Rx<ServiceSubcategory?>(null);

  StreamSubscription<List<ServiceCategory>>? _categorySub;

  // ── Form fields ───────────────────────────────────────────────
  final TextEditingController detailsController = TextEditingController();
  final TextEditingController minController = TextEditingController();
  final TextEditingController maxController = TextEditingController();

  final Rx<RangeValues> budgetRange = const RangeValues(50, 150).obs;
  final RxString selectedPayment = 'card'.obs;
  final Rx<DateTime?> selectedDate = Rx<DateTime?>(null);
  final Rx<TimeOfDay?> selectedTime = Rx<TimeOfDay?>(null);
  final RxList<File> pickedImages = <File>[].obs;

  // ── Submission state ──────────────────────────────────────────
  final RxBool isSubmitting = false.obs;

  final ImagePicker _picker = ImagePicker();

  // ── Optional: pre-select category (e.g. from fixer's profile) ─
  String? preselectedCategoryName;

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

        // Auto-select if fixer's category was passed in
        if (preselectedCategoryName != null &&
            selectedCategory.value == null) {
          final match = data.firstWhereOrNull(
                (c) =>
            c.name.toLowerCase() ==
                preselectedCategoryName!.toLowerCase(),
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
    if (parsed != null &&
        parsed >= budgetRange.value.start &&
        parsed <= 10000) {
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

  // ── Upload images ─────────────────────────────────────────────
  Future<List<String>> _uploadImages(String bookingId) async {
    if (pickedImages.isEmpty) return [];
    final urls = <String>[];
    for (int i = 0; i < pickedImages.length; i++) {
      final ref = FirebaseStorage.instance
          .ref('booking_images/$bookingId/image_$i.jpg');
      await ref.putFile(pickedImages[i]);
      urls.add(await ref.getDownloadURL());
    }
    return urls;
  }

  // ── Create booking in Firestore ───────────────────────────────
  Future<String?> createBooking({VoidCallback? onSuccess}) async {
    if (isSubmitting.value) return null;
    isSubmitting.value = true;

    try {
      final clientId = FirebaseAuth.instance.currentUser?.uid ?? '';
      final now = DateTime.now();

      // Pre-reserve doc ID so Storage paths align before write
      final docRef =
      FirebaseFirestore.instance.collection('bookings').doc();
      final bookingId = docRef.id;

      final imageUrls = await _uploadImages(bookingId);

      final scheduledAt = DateTime(
        selectedDate.value!.year,
        selectedDate.value!.month,
        selectedDate.value!.day,
        selectedTime.value!.hour,
        selectedTime.value!.minute,
      );

      final loc = locationController.currentLocation.value;

      final booking = BookingModel(
        id: bookingId,
        clientId: clientId,
        fixerId: fixerId, // ← the specific fixer
        categoryId: selectedCategory.value!.id,
        categoryName: selectedCategory.value!.name,
        subcategoryId: selectedSubcategory.value!.id,
        subcategoryName: selectedSubcategory.value!.name,
        details: detailsController.text.trim(),
        imageUrls: imageUrls,
        address: loc?.address ?? '',
        lat: loc?.lat ?? 0.0,
        lng: loc?.lng ?? 0.0,
        scheduledAt: scheduledAt,
        budgetMin: budgetRange.value.start.round(),
        budgetMax: budgetRange.value.end.round(),
        paymentMethod: selectedPayment.value,
        status: BookingStatus.pending,
        createdAt: now,
        updatedAt: now,
      );

      await _bookingRepo.createBooking(booking);
      onSuccess?.call();
      return bookingId;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create booking: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    } finally {
      isSubmitting.value = false;
    }
  }

  // ── Payload for ConfirmationDialog (display only) ─────────────
  Map<String, dynamic> buildDisplayPayload(BuildContext context) {
    return {
      'categoryName': selectedCategory.value!.name,
      'subcategoryName': selectedSubcategory.value?.name,
      'details': detailsController.text.trim(),
      'location': locationController.currentLocation.value?.address ?? '',
      'date': selectedDate.value!.toIso8601String(),
      'time': selectedTime.value!.format(context),
      'budgetMin': budgetRange.value.start.round(),
      'budgetMax': budgetRange.value.end.round(),
      'payment': selectedPayment.value,
      'images': List<File>.from(pickedImages),
      // forAll is always false for bookings — direct to one fixer
      'forAll': false,
    };
  }
}