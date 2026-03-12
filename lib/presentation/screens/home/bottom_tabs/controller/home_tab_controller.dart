import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../domain/models/fixxer_model.dart';
import '../../../../../domain/models/location_model.dart';
import '../../../../../domain/models/service_subcategory.dart';
import '../../../../../domain/repos/fixxer_repo.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Job Request Model
// ─────────────────────────────────────────────────────────────────────────────

class JobRequestModel {
  final String id;
  final String userId;
  final String categoryName;
  final String subcategoryName;
  final String address;
  final double budgetMin;
  final double budgetMax;
  final String details;
  final String status;
  final bool isOpenForAll;
  final String? providerId;
  final String paymentMethod;
  final List<String> imageUrls;
  final DateTime? scheduledAt;
  final DateTime? createdAt;

  JobRequestModel({
    required this.id,
    required this.userId,
    required this.categoryName,
    required this.subcategoryName,
    required this.address,
    required this.budgetMin,
    required this.budgetMax,
    required this.details,
    required this.status,
    required this.isOpenForAll,
    this.providerId,
    required this.paymentMethod,
    required this.imageUrls,
    this.scheduledAt,
    this.createdAt,
  });

  factory JobRequestModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return JobRequestModel(
      id: doc.id,
      userId: d['userId'] as String? ?? '',
      categoryName: d['categoryName'] as String? ?? '',
      subcategoryName: d['subcategoryName'] as String? ?? '',
      address: d['address'] as String? ?? '',
      budgetMin: (d['budgetMin'] as num?)?.toDouble() ?? 0,
      budgetMax: (d['budgetMax'] as num?)?.toDouble() ?? 0,
      details: d['details'] as String? ?? '',
      status: d['status'] as String? ?? 'pending',
      isOpenForAll: d['isOpenForAll'] as bool? ?? true,
      providerId: d['providerId'] as String?,
      paymentMethod: d['paymentMethod'] as String? ?? '',
      imageUrls: List<String>.from(d['imageUrls'] as List? ?? []),
      scheduledAt: (d['scheduledAt'] as Timestamp?)?.toDate(),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Haversine distance helper
// ─────────────────────────────────────────────────────────────────────────────

double _distanceKm(double lat1, double lon1, double lat2, double lon2) {
  const r = 6371.0;
  final dLat = _deg2rad(lat2 - lat1);
  final dLon = _deg2rad(lon2 - lon1);
  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) *
          sin(dLon / 2) * sin(dLon / 2);
  return r * 2 * atan2(sqrt(a), sqrt(1 - a));
}

double _deg2rad(double deg) => deg * pi / 180;

// ─────────────────────────────────────────────────────────────────────────────
// HomeController
// ─────────────────────────────────────────────────────────────────────────────

class HomeController extends GetxController {
  final FixxerRepo _repo;
  final FirebaseAuth _auth;
  final _db = FirebaseFirestore.instance;

  HomeController({FixxerRepo? repo, FirebaseAuth? auth})
      : _repo = repo ?? FixxerRepo(),
        _auth = auth ?? FirebaseAuth.instance;

  // ── Current fixer user (fixer app) ───────────────────────────────
  final Rxn<FixxerUser> user = Rxn<FixxerUser>();
  final RxBool isLoading = false.obs;

  // ── Jobs (fixer app) ─────────────────────────────────────────────
  final RxList<JobRequestModel> newJobs = <JobRequestModel>[].obs;
  final RxList<JobRequestModel> myBookings = <JobRequestModel>[].obs;
  final RxBool isLoadingJobs = true.obs;
  final RxBool isLoadingBookings = true.obs;

  // ── Popular subcategories (client app) ───────────────────────────
  final RxList<ServiceSubcategory> popularSubcategories = <ServiceSubcategory>[].obs;
  final RxBool isLoadingPopular = false.obs;

  // ── Nearby fixxers (client app) ──────────────────────────────────
  final RxList<FixxerUser> nearbyFixxers = <FixxerUser>[].obs;
  final RxBool isLoadingNearby = false.obs;

  StreamSubscription? _openJobsSub;
  StreamSubscription? _directJobsSub;
  StreamSubscription? _bookingsSub;

  List<JobRequestModel> _openJobs = [];
  List<JobRequestModel> _directJobs = [];

  String get myId => _auth.currentUser?.uid ?? '';

  // ── Lifecycle ─────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    fetchUser().then((_) {
      _listenToNewJobs();
      _listenToMyBookings();
      fetchPopularSubcategories();
      fetchNearbyFixxers();
    });
  }

  @override
  void onClose() {
    _openJobsSub?.cancel();
    _directJobsSub?.cancel();
    _bookingsSub?.cancel();
    super.onClose();
  }

  // ── Fetch current user ────────────────────────────────────────────

  Future<void> fetchUser() async {
    try {
      isLoading.value = true;
      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        await _auth.currentUser?.reload();
        if (_auth.currentUser?.uid == null) return;
      }
      final resolvedUid = _auth.currentUser!.uid;
      final fetchedUser = await _repo.getFixxer(resolvedUid);
      if (fetchedUser == null) {
        debugPrint('▶ HomeController: no fixxer doc for uid=$resolvedUid');
        return;
      }
      user.value = fetchedUser;
    } catch (e) {
      debugPrint('▶ fetchUser error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ── Popular subcategories ─────────────────────────────────────────
  // Reads 'popular' collection where each doc has a 'subcategoryId' field,
  // then fetches the matching service_subcategories docs.

  Future<void> fetchPopularSubcategories() async {
    try {
      isLoadingPopular.value = true;

      final popularSnap = await _db.collection('popular').get();
      if (popularSnap.docs.isEmpty) {
        debugPrint('▶ popular collection is empty');
        return;
      }

      // Extract subcategory IDs — prefer 'subcategoryId' field, fall back to doc ID
      final ids = popularSnap.docs
          .map((doc) => (doc.data()['subcategoryId'] as String?) ?? doc.id)
          .where((id) => id.isNotEmpty)
          .toList();

      // Fetch subcategory docs in chunks of 10 (Firestore whereIn limit)
      final results = <ServiceSubcategory>[];
      for (int i = 0; i < ids.length; i += 10) {
        final chunk = ids.sublist(i, min(i + 10, ids.length));
        try {
          final snap = await _db
              .collection('service_subcategories')
              .where(FieldPath.documentId, whereIn: chunk)
              .get();
          for (final doc in snap.docs) {
            try {
              results.add(ServiceSubcategory.fromDoc(doc));
            } catch (_) {}
          }
        } catch (e) {
          debugPrint('▶ fetchPopularSubcategories chunk error: $e');
        }
      }

      popularSubcategories.value = results;
      debugPrint('▶ fetchPopularSubcategories: loaded \${results.length}');
    } catch (e) {
      debugPrint('▶ fetchPopularSubcategories error: $e');
    } finally {
      isLoadingPopular.value = false;
    }
  }

  // ── Nearby fixxers ────────────────────────────────────────────────
  // Reads current user's location from Firestore 'users' collection,
  // then returns all fixxers within 20 km (Haversine formula).
  // Can also accept a LocationModel directly (e.g. from LocationController).

  Future<void> fetchNearbyFixxers({LocationModel? userLocation}) async {
    try {
      isLoadingNearby.value = true;

      double? userLat;
      double? userLng;

      // 1. Use provided location if given (fastest — from LocationController)
      if (userLocation != null &&
          (userLocation.lat != 0 || userLocation.lng != 0)) {
        userLat = userLocation.lat;
        userLng = userLocation.lng;
      } else {
        // 2. Fall back to reading from Firestore 'users' collection
        final uid = _auth.currentUser?.uid;
        if (uid == null) return;

        final userDoc = await _db.collection('users').doc(uid).get();
        final loc = userDoc.data()?['location'];
        if (loc == null) {
          debugPrint('▶ fetchNearbyFixxers: no location in users/$uid');
          return;
        }
        userLat = (loc['lat'] as num?)?.toDouble() ?? 0;
        userLng = (loc['lng'] as num?)?.toDouble() ?? 0;
      }

      if (userLat == 0 && userLng == 0) {
        debugPrint('▶ fetchNearbyFixxers: lat/lng is 0,0 — skipping');
        return;
      }

      // 3. Fetch all fixxers and filter by distance
      final snap = await _db.collection('fixxers').get();
      final nearby = <_FixxerWithDistance>[];

      for (final doc in snap.docs) {
        try {
          final data = doc.data();
          final loc = data['location'];
          if (loc == null) continue;

          final fixerLat = (loc['lat'] as num?)?.toDouble();
          final fixerLng = (loc['lng'] as num?)?.toDouble();
          if (fixerLat == null || fixerLng == null) continue;
          if (fixerLat == 0 && fixerLng == 0) continue;

          final distKm = _distanceKm(userLat!, userLng!, fixerLat, fixerLng);
          if (distKm <= 20.0) {
            nearby.add(_FixxerWithDistance(
              fixxer: FixxerUser.fromMap(data),
              distanceKm: distKm,
            ));
          }
        } catch (_) {
          continue;
        }
      }

      // Sort by distance ascending (closest first)
      nearby.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
      nearbyFixxers.value = nearby.map((e) => e.fixxer).toList();

      debugPrint('▶ fetchNearbyFixxers: found ${nearbyFixxers.length} within 20km');
    } catch (e) {
      debugPrint('▶ fetchNearbyFixxers error: $e');
    } finally {
      isLoadingNearby.value = false;
    }
  }

  // ── Shared: fetch fixxers by list of IDs ──────────────────────────
  // Firestore 'whereIn' max = 10, so we chunk the list.

  Future<List<FixxerUser>> _fetchFixxersByIds(List<String> ids) async {
    final results = <FixxerUser>[];
    for (int i = 0; i < ids.length; i += 10) {
      final chunk = ids.sublist(i, min(i + 10, ids.length));
      try {
        final snap = await _db
            .collection('fixxers')
            .where(FieldPath.documentId, whereIn: chunk)
            .get();
        for (final doc in snap.docs) {
          try {
            results.add(FixxerUser.fromMap(doc.data()));
          } catch (_) {}
        }
      } catch (e) {
        debugPrint('▶ _fetchFixxersByIds chunk error: $e');
      }
    }
    return results;
  }

  // ── Jobs streams (fixer app) ──────────────────────────────────────

  void _listenToNewJobs() {
    if (myId.isEmpty) {
      isLoadingJobs.value = false;
      return;
    }

    _openJobsSub = _db
        .collection('job_requests')
        .where('isOpenForAll', isEqualTo: true)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .limit(10)
        .snapshots()
        .listen((snap) {
      _openJobs = snap.docs.map((d) => JobRequestModel.fromDoc(d)).toList();
      _mergeJobs();
    }, onError: (e) {
      debugPrint('▶ open jobs error: $e');
      isLoadingJobs.value = false;
    });

    _directJobsSub = _db
        .collection('job_requests')
        .where('providerId', isEqualTo: myId)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .limit(10)
        .snapshots()
        .listen((snap) {
      _directJobs = snap.docs.map((d) => JobRequestModel.fromDoc(d)).toList();
      _mergeJobs();
    }, onError: (e) {
      debugPrint('▶ direct jobs error: $e');
      isLoadingJobs.value = false;
    });
  }

  void _mergeJobs() {
    final seen = <String>{};
    final merged = [..._openJobs, ..._directJobs]
        .where((j) => seen.add(j.id))
        .toList()
      ..sort((a, b) =>
          (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
    newJobs.value = merged;
    isLoadingJobs.value = false;
  }

  void _listenToMyBookings() {
    if (myId.isEmpty) {
      isLoadingBookings.value = false;
      return;
    }

    _bookingsSub = _db
        .collection('bookings')
        .where('fixerId', isEqualTo: myId)
        .where('status',
        whereIn: ['pending', 'accepted', 'underReview', 'inProgress', 'ongoing'])
        .orderBy('scheduledAt', descending: true)
        .limit(20)
        .snapshots()
        .listen((snap) {
      myBookings.value =
          snap.docs.map((d) => JobRequestModel.fromDoc(d)).toList();
      isLoadingBookings.value = false;
    }, onError: (e) {
      debugPrint('▶ bookings error: $e');
      isLoadingBookings.value = false;
    });
  }
}

// Internal helper — not exposed outside this file
class _FixxerWithDistance {
  final FixxerUser fixxer;
  final double distanceKm;
  _FixxerWithDistance({required this.fixxer, required this.distanceKm});
}