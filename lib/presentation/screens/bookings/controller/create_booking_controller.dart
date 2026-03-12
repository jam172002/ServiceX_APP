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
import '../../../../domain/models/fixer_model.dart';
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

  // ── Fixer — set once from screen initState ────────────────────
  late final FixerModel fixer;

  // ── Category is fixed — taken directly from fixer ─────────────
  // Reactive so _buildFixedCategoryRow redraws once Firestore resolves the name.
  String fixerCategoryId = '';
  final RxString fixerCategoryName = ''.obs;

  // ── Subcategories — only the fixer's own subs ─────────────────
  final RxList<ServiceSubcategory> subcategories = <ServiceSubcategory>[].obs;
  final RxBool subcategoriesLoading = true.obs;
  final Rx<ServiceSubcategory?> selectedSubcategory =
  Rx<ServiceSubcategory?>(null);

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

  // ─────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    minController.text = budgetRange.value.start.round().toString();
    maxController.text = budgetRange.value.end.round().toString();
  }

  /// Called from screen initState after [fixer] is set.
  /// Fetches only the subcategories that belong to this fixer.
  Future<void> loadFixerSubcategories() async {
    if (fixer.subCategories.isEmpty) {
      subcategoriesLoading.value = false;
      return;
    }

    subcategoriesLoading.value = true;
    try {
      // Fetch each subcategory doc by ID — fixer.subCategories is List<String>
      final docs = await Future.wait(
        fixer.subCategories.map(
              (id) => FirebaseFirestore.instance
              .collection('service_subcategories')
              .doc(id)
              .get(),
        ),
      );

      final subs = docs
          .where((d) => d.exists)
          .map((d) => ServiceSubcategory.fromDoc(d))
          .toList();

      subcategories.assignAll(subs);

      // Resolve the category name from Firestore for display + storage
      if (fixer.mainCategory.isNotEmpty) {
        fixerCategoryId = fixer.mainCategory;
        final catDoc = await FirebaseFirestore.instance
            .collection('service_categories')
            .doc(fixer.mainCategory)
            .get();
        fixerCategoryName.value =
            (catDoc.data()?['name'] as String?) ?? fixer.mainCategory;
      }
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
        fixerId: fixer.uid,
        fixerName: fixer.fullName,
        fixerImageUrl: fixer.profileImageUrl,
        categoryId: fixerCategoryId,
        categoryName: fixerCategoryName.value,
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

  // ── Payload for ConfirmationDialog ────────────────────────────
  Map<String, dynamic> buildDisplayPayload(BuildContext context) {
    return {
      'categoryName': fixerCategoryName.value,
      'subcategoryName': selectedSubcategory.value?.name,
      'details': detailsController.text.trim(),
      'location': locationController.currentLocation.value?.address ?? '',
      'date': selectedDate.value!.toIso8601String(),
      'time': selectedTime.value!.format(context),
      'budgetMin': budgetRange.value.start.round(),
      'budgetMax': budgetRange.value.end.round(),
      'payment': selectedPayment.value,
      'images': List<File>.from(pickedImages),
      'forAll': false,
    };
  }

  @override
  void onClose() {
    detailsController.dispose();
    minController.dispose();
    maxController.dispose();
    super.onClose();
  }
}