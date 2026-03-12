import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:servicex_client_app/domain/models/service_category.dart';
import 'package:servicex_client_app/domain/models/service_subcategory.dart';
import 'package:servicex_client_app/domain/repos/repo_providers.dart';

import '../../../domain/models/fixxer_model.dart';

class SearchFilters {
  final double? minRate;
  final double? maxRate;
  final double? minRating;
  final String? gender;       // 'Male' | 'Female' | null = any
  final String? categoryId;   // null = any
  final List<String> availableDays; // empty = any

  const SearchFilters({
    this.minRate,
    this.maxRate,
    this.minRating,
    this.gender,
    this.categoryId,
    this.availableDays = const [],
  });

  bool get isActive =>
      minRate != null ||
          maxRate != null ||
          minRating != null ||
          gender != null ||
          categoryId != null ||
          availableDays.isNotEmpty;

  SearchFilters copyWith({
    double? minRate,
    double? maxRate,
    double? minRating,
    String? gender,
    String? categoryId,
    List<String>? availableDays,
    bool clearGender = false,
    bool clearCategory = false,
    bool clearMinRating = false,
  }) {
    return SearchFilters(
      minRate: minRate ?? this.minRate,
      maxRate: maxRate ?? this.maxRate,
      minRating: clearMinRating ? null : (minRating ?? this.minRating),
      gender: clearGender ? null : (gender ?? this.gender),
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      availableDays: availableDays ?? this.availableDays,
    );
  }

  static const empty = SearchFilters();
}

class XSearchController extends GetxController {
  final RxString searchQuery = ''.obs;

  // ── Raw data ─────────────────────────────────────────────────────────────
  final RxList<ServiceCategory> _cats = <ServiceCategory>[].obs;
  final RxList<ServiceSubcategory> _subs = <ServiceSubcategory>[].obs;
  final RxList<FixxerUser> _fixxers = <FixxerUser>[].obs;

  // ── Filters ───────────────────────────────────────────────────────────────
  final Rx<SearchFilters> activeFilters = SearchFilters.empty.obs;

  // ── Loading ───────────────────────────────────────────────────────────────
  final RxBool isLoadingFixxers = true.obs;

  StreamSubscription? _cSub;
  StreamSubscription? _sSub;
  StreamSubscription? _fSub;

  @override
  void onInit() {
    super.onInit();
    _cSub = servicesRepo.watchCategories().listen((d) => _cats.assignAll(d));
    _sSub = servicesRepo.watchAllSubcategories().listen((d) => _subs.assignAll(d));
    _listenFixxers();
  }

  void _listenFixxers() {
    isLoadingFixxers.value = true;
    _fSub?.cancel();
    _fSub = FirebaseFirestore.instance
        .collection('fixxers')
        .where('profileComplete', isEqualTo: true)
        .snapshots()
        .listen((snap) {
      _fixxers.assignAll(
        snap.docs.map((d) {
          final data = d.data();
          data['uid'] = d.id;
          return FixxerUser.fromMap(data);
        }).toList(),
      );
      isLoadingFixxers.value = false;
    }, onError: (_) => isLoadingFixxers.value = false);
  }

  @override
  void onClose() {
    _cSub?.cancel();
    _sSub?.cancel();
    _fSub?.cancel();
    super.onClose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  ServiceCategory? categoryById(String id) {
    try { return _cats.firstWhere((c) => c.id == id); } catch (_) { return null; }
  }

  List<ServiceCategory> get allCategories => _cats.toList();

  // ── Filtered results ──────────────────────────────────────────────────────

  List<ServiceCategory> get filteredCategories {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return _cats.where((c) => c.name.toLowerCase().contains(q)).toList();
  }

  List<ServiceSubcategory> get filteredServices {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return const [];
    var results = _subs.where((s) => s.name.toLowerCase().contains(q)).toList();
    // Filter by category if set
    final f = activeFilters.value;
    if (f.categoryId != null) {
      results = results.where((s) => s.categoryId == f.categoryId).toList();
    }
    return results;
  }

  List<FixxerUser> get filteredFixxers {
    final q = searchQuery.value.trim().toLowerCase();
    final f = activeFilters.value;

    if (q.isEmpty && !f.isActive) return const [];

    return _fixxers.where((fx) {
      // Query match
      final matchesQuery = q.isEmpty ||
          fx.fullName.toLowerCase().contains(q) ||
          (fx.bio?.toLowerCase().contains(q) ?? false) ||
          (fx.mainCategory?.toLowerCase().contains(q) ?? false) ||
          fx.subCategories.any((s) => s.toLowerCase().contains(q));

      if (!matchesQuery) return false;

      // Rate filter
      if (f.minRate != null && (fx.hourlyRate ?? 0) < f.minRate!) return false;
      if (f.maxRate != null && (fx.hourlyRate ?? double.infinity) > f.maxRate!) return false;

      // Rating filter
      if (f.minRating != null && fx.rating < f.minRating!) return false;

      // Gender filter
      if (f.gender != null &&
          fx.gender.toLowerCase() != f.gender!.toLowerCase()) return false;

      // Category filter
      if (f.categoryId != null && fx.mainCategory != f.categoryId) return false;

      // Available days filter
      if (f.availableDays.isNotEmpty) {
        final hasDay = f.availableDays.any((d) => fx.availableDays.contains(d));
        if (!hasDay) return false;
      }

      return true;
    }).toList()
      ..sort((a, b) => b.rating.compareTo(a.rating));
  }

  void applyFilters(SearchFilters filters) => activeFilters.value = filters;
  void clearFilters() => activeFilters.value = SearchFilters.empty;
}