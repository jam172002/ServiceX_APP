import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/fixer_model.dart';


class FixxerRepo {
  final FirebaseFirestore _db;
  final FirebaseStorage _storage;

  FixxerRepo({
    FirebaseFirestore? db,
    FirebaseStorage? storage,
  })  : _db = db ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _db.collection('fixxers').doc(uid);

  // ── Read ────────────────────────────────────────────────────────

  Future<FixerModel?> getFixxer(String uid) async {
    final snap = await _doc(uid).get();
    if (!snap.exists || snap.data() == null) return null;
    return FixerModel.fromMap(snap.data()!);
  }

  /// Stream a single fixer's doc — UI rebuilds automatically on change
  Stream<FixerModel?> streamFixxer(String uid) {
    return _doc(uid).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return FixerModel.fromMap(snap.data()!);
    });
  }

  // ── Write ───────────────────────────────────────────────────────

  Future<void> createFixxer(FixerModel user) async {
    await _doc(user.uid).set(user.toMap(), SetOptions(merge: true));
  }

  /// Partial update — pass only the fields you want to change.
  /// Always stamps updatedAt via serverTimestamp.
  Future<void> updateFixxer(String uid, Map<String, dynamic> fields) async {
    await _doc(uid).set(
      {...fields, 'updatedAt': FieldValue.serverTimestamp()},
      SetOptions(merge: true),
    );
  }

  // ── Images ──────────────────────────────────────────────────────

  Future<String> uploadFixxerImage({
    required String uid,
    required File file,
    required String pathName, // e.g. 'profile.jpg', 'banner.jpg'
  }) async {
    final ref = _storage.ref().child('fixxers/$uid/$pathName');
    await ref.putFile(file, SettableMetadata(contentType: 'image/jpeg'));
    return ref.getDownloadURL();
  }

  // ── Queries ─────────────────────────────────────────────────────

  Future<List<FixerModel>> getFixxersByCategory(String categoryId) async {
    final snap = await _db
        .collection('fixxers')
        .where('mainCategory', isEqualTo: categoryId)
        .get();
    return _mapDocs(snap);
  }

  Future<List<FixerModel>> getFixxersBySubcategory(String subcategoryId) async {
    final snap = await _db
        .collection('fixxers')
        .where('subCategories', arrayContains: subcategoryId)
        .get();
    return _mapDocs(snap);
  }

  /// Popular fixxers — reads IDs from 'popular' collection,
  /// then fetches the matching fixxer docs in chunks of 10.
  Future<List<FixerModel>> getPopularFixxers() async {
    final popularSnap = await _db.collection('popular').get();
    if (popularSnap.docs.isEmpty) return [];

    final ids = popularSnap.docs
        .map((d) => (d.data()['fixerId'] as String?) ?? d.id)
        .where((id) => id.isNotEmpty)
        .toList();

    final results = <FixerModel>[];
    for (int i = 0; i < ids.length; i += 10) {
      final chunk = ids.sublist(i, (i + 10).clamp(0, ids.length));
      final snap = await _db
          .collection('fixxers')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      results.addAll(_mapDocs(snap));
    }
    results.sort((a, b) => (b.hourlyRate).compareTo(a.hourlyRate));
    return results;
  }

  /// All fixxers — used for client-side nearby distance filtering
  Future<List<FixerModel>> getAllFixxers() async {
    final snap = await _db.collection('fixxers').get();
    return _mapDocs(snap);
  }

  // ── Booking stats ────────────────────────────────────────────────
  // Uses correct JobStatus enum strings

  Future<Map<String, int>> getBookingStats(String uid) async {
    final snap = await _db
        .collection('bookings')
        .where('fixerId', isEqualTo: uid)
        .get();

    int upcoming = 0, active = 0, completed = 0, cancelled = 0;

    for (final doc in snap.docs) {
      final status = (doc.data()['status'] ?? '') as String;
      switch (status) {
        case 'newRequest':
        case 'pending':
        case 'underReview':
        case 'accepted':
          upcoming++;
          break;
        case 'inProgress':
        case 'ongoing':
          active++;
          break;
        case 'completed':
          completed++;
          break;
        case 'cancelled':
          cancelled++;
          break;
      }
    }

    return {
      'upcoming': upcoming,
      'active': active,
      'completed': completed,
      'cancelled': cancelled,
    };
  }

  // ── FCM token ────────────────────────────────────────────────────

  Future<void> saveFcmToken(String uid, String token) async {
    await updateFixxer(uid, {'fcmToken': token});
  }

  // ── Helper ───────────────────────────────────────────────────────

  List<FixerModel> _mapDocs(QuerySnapshot<Map<String, dynamic>> snap) {
    final results = <FixerModel>[];
    for (final doc in snap.docs) {
      try {
        results.add(FixerModel.fromMap(doc.data()));
      } catch (e) {
        // skip malformed docs silently
      }
    }
    return results;
  }
}