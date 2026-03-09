import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:servicex_client_app/domain/models/fixer_model.dart';
import 'package:servicex_client_app/domain/models/service_subcategory.dart';
import 'package:servicex_client_app/domain/repos/service_catalog_repo.dart';

class SubcategoriesController extends GetxController {
  final String categoryId;
  final ServiceCatalogRepo _repo;
  final FirebaseFirestore _db;

  SubcategoriesController({
    required this.categoryId,
    ServiceCatalogRepo? repo,
    FirebaseFirestore? db,
  })  : _repo = repo ?? ServiceCatalogRepo(FirebaseFirestore.instance),
        _db = db ?? FirebaseFirestore.instance;

  // ── Subcategories state ───────────────────────────────────────
  final RxList<ServiceSubcategory> subcategories = <ServiceSubcategory>[].obs;
  final RxBool subsLoading = true.obs;
  final RxString subsError = ''.obs;

  // ── Fixxers state (for selected subcategory) ──────────────────
  final RxList<FixerModel> fixxers = <FixerModel>[].obs;
  final RxBool fixxersLoading = false.obs;
  final RxString fixxersError = ''.obs;
  final Rxn<ServiceSubcategory> selectedSubcategory = Rxn();

  StreamSubscription<List<ServiceSubcategory>>? _subsSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _fixxersSub;

  @override
  void onInit() {
    super.onInit();
    _loadSubcategories();
  }

  void _loadSubcategories() {
    subsLoading.value = true;
    subsError.value = '';
    _subsSub?.cancel();

    _subsSub = _repo
        .watchSubcategories(categoryId)
        .listen(
          (data) {
        subcategories.assignAll(data);
        subsLoading.value = false;
      },
      onError: (e) {
        subsError.value = e.toString();
        subsLoading.value = false;
      },
    );
  }

  /// Called when user taps a subcategory tile or "See all"
  void loadFixxersForSubcategory(ServiceSubcategory sub) {
    if (selectedSubcategory.value?.id == sub.id) return;
    selectedSubcategory.value = sub;
    fixxers.clear();
    fixxersError.value = '';
    fixxersLoading.value = true;

    _fixxersSub?.cancel();
    _fixxersSub = _db
        .collection('fixxers')
        .where('subCategories', arrayContains: sub.id)
        .snapshots()
        .listen(
          (snap) {
        fixxers.assignAll(
          snap.docs.map((d) => FixerModel.fromDoc(d)).toList(),
        );
        fixxersLoading.value = false;
      },
      onError: (e) {
        fixxersError.value = e.toString();
        fixxersLoading.value = false;
      },
    );
  }

  @override
  void onClose() {
    _subsSub?.cancel();
    _fixxersSub?.cancel();
    super.onClose();
  }
}

// ── Extension so catalog repo can also stream subcategories ──────
extension SubWatch on ServiceCatalogRepo {
  Stream<List<ServiceSubcategory>> watchSubcategories(String categoryId) {
    return FirebaseFirestore.instance
        .collection('service_subcategories')
        .where('categoryId', isEqualTo: categoryId)
        .orderBy('name')
        .snapshots()
        .map((snap) =>
        snap.docs.map((doc) => ServiceSubcategory.fromDoc(doc)).toList());
  }
}