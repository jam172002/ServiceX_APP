import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/service_category.dart';
import '../models/service_subcategory.dart';

/// Central repo for service categories and subcategories.
/// Used by:
///   - CreateJobController  → watchCategories(), getSubcategories(categoryId)
///   - XSearchController    → watchCategories(), watchAllSubcategories()
///   - CategoryRepository   → can be replaced by this entirely
class ServiceCatalogRepo {
  final FirebaseFirestore _db;

  ServiceCatalogRepo(this._db);

  // ── Collections ───────────────────────────────────────────────
  CollectionReference<Map<String, dynamic>> get _categoriesCol =>
      _db.collection('service_categories');

  CollectionReference<Map<String, dynamic>> get _subcategoriesCol =>
      _db.collection('service_subcategories');

  // ── Categories ────────────────────────────────────────────────

  /// Live stream of all categories, ordered by name.
  /// Used by: CreateJobController, XSearchController
  Stream<List<ServiceCategory>> watchCategories() {
    return _categoriesCol.orderBy('name').snapshots().map(
          (snap) => snap.docs
          .map((doc) => ServiceCategory.fromDoc(doc))
          .toList(),
    );
  }

  /// One-shot fetch of all categories.
  Future<List<ServiceCategory>> getCategories() async {
    final snap = await _categoriesCol.orderBy('name').get();
    return snap.docs.map((doc) => ServiceCategory.fromDoc(doc)).toList();
  }

  // ── Subcategories ─────────────────────────────────────────────

  /// Live stream of ALL subcategories (used by XSearchController for search).
  Stream<List<ServiceSubcategory>> watchAllSubcategories() {
    return _subcategoriesCol.orderBy('name').snapshots().map(
          (snap) => snap.docs
          .map((doc) => ServiceSubcategory.fromDoc(doc))
          .toList(),
    );
  }

  /// Fetches subcategories for a specific category (used when user taps a chip).
  /// Used by: CreateJobController.selectCategory()
  Future<List<ServiceSubcategory>> getSubcategories(String categoryId) async {
    final snap = await _subcategoriesCol
        .where('categoryId', isEqualTo: categoryId)
        .orderBy('name')
        .get();
    return snap.docs
        .map((doc) => ServiceSubcategory.fromDoc(doc))
        .toList();
  }

  /// One-shot fetch of ALL subcategories (non-streaming alternative).
  Future<List<ServiceSubcategory>> getAllSubcategories() async {
    final snap = await _subcategoriesCol.orderBy('name').get();
    return snap.docs.map((doc) => ServiceSubcategory.fromDoc(doc)).toList();
  }
}