import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../../domain/models/service_category.dart';
import '../../../../domain/models/service_subcategory.dart';
import '../../../../domain/repos/service_catalog_repo.dart';

class CategoryController extends GetxController {
  final ServiceCatalogRepo _repo =
  ServiceCatalogRepo(FirebaseFirestore.instance);

  final RxList<ServiceCategory> categories = <ServiceCategory>[].obs;
  final RxList<ServiceSubcategory> subcategories = <ServiceSubcategory>[].obs;

  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;

  StreamSubscription<List<ServiceCategory>>? _catSub;
  StreamSubscription<List<ServiceSubcategory>>? _subSub;

  @override
  void onInit() {
    super.onInit();
    _listen();
  }

  void _listen() {
    isLoading.value = true;
    error.value = '';

    // ── Categories ───────────────────────────────────────────────
    _catSub?.cancel();
    _catSub = _repo.watchCategories().listen(
          (data) {
        categories.assignAll(data);
        _checkDone();
      },
      onError: (e) {
        error.value = e.toString();
        isLoading.value = false;
      },
    );

    // ── Subcategories ────────────────────────────────────────────
    _subSub?.cancel();
    _subSub = _repo.watchAllSubcategories().listen(
          (data) {
        subcategories.assignAll(data);
        _checkDone();
      },
      onError: (e) {
        error.value = e.toString();
        isLoading.value = false;
      },
    );
  }

  // Stop loading once both streams have delivered at least one value
  void _checkDone() {
    if (categories.isNotEmpty || subcategories.isNotEmpty) {
      isLoading.value = false;
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────

  /// Returns the display name for a category ID, or empty string if not found.
  String categoryName(String? id) {
    if (id == null || id.isEmpty) return '';
    try {
      return categories.firstWhere((c) => c.id == id).name;
    } catch (_) {
      return '';
    }
  }

  /// Returns the display name for a subcategory ID, or empty string if not found.
  String subcategoryName(String? id) {
    if (id == null || id.isEmpty) return '';
    try {
      return subcategories.firstWhere((s) => s.id == id).name;
    } catch (_) {
      return '';
    }
  }

  @override
  void onClose() {
    _catSub?.cancel();
    _subSub?.cancel();
    super.onClose();
  }
}