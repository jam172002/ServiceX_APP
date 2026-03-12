import 'package:cloud_firestore/cloud_firestore.dart';

/// Lightweight location wrapper so code can use `fixxer.location.address`
/// the same way as FixxerUser, without changing the flat lat/lng/address fields.
class _FixerLocation {
  final String address;
  final double lat;
  final double lng;
  const _FixerLocation({
    required this.address,
    required this.lat,
    required this.lng,
  });
  bool get isNotEmpty => address.isNotEmpty;
}

class FixerModel {
  final String uid;
  final String fullName;
  final String email;
  final String phone;
  final String gender;
  final String bio;
  final String profileImageUrl;
  final String bannerImageUrl;
  final String mainCategory;
  final List<String> subCategories;
  final List<String> availableDays;
  final List<String> languages;
  final List<String> serviceImages;
  final double hourlyRate;
  final int maxBookingsPerDay;
  final int yearsOfExperience;
  final bool profileComplete;
  final double lat;
  final double lng;
  final String address;
  final double rating;
  final int totalReviews;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? fcmToken;

  // Convenience getter — lets code use `fixxer.location.address` / `.lat` / `.lng`
  // just like FixxerUser, without changing the flat storage fields.
  _FixerLocation get location =>
      _FixerLocation(address: address, lat: lat, lng: lng);

  FixerModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.gender,
    required this.bio,
    required this.profileImageUrl,
    required this.bannerImageUrl,
    required this.mainCategory,
    required this.subCategories,
    required this.availableDays,
    required this.languages,
    required this.hourlyRate,
    required this.maxBookingsPerDay,
    required this.yearsOfExperience,
    required this.profileComplete,
    required this.lat,
    required this.lng,
    required this.address,
    required this.createdAt,
    required this.updatedAt,
    this.serviceImages = const [],
    this.rating = 0.0,
    this.totalReviews = 0,
    this.fcmToken,
  });

  // ── fromDoc (Firestore DocumentSnapshot) ─────────────────────────────────
  factory FixerModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    final loc = d['location'] as Map<String, dynamic>? ?? {};
    return FixerModel(
      uid: doc.id,
      fullName: (d['fullName'] ?? '') as String,
      email: (d['email'] ?? '') as String,
      phone: (d['phone'] ?? '') as String,
      gender: (d['gender'] ?? '') as String,
      bio: (d['bio'] ?? '') as String,
      profileImageUrl: (d['profileImageUrl'] ?? '') as String,
      bannerImageUrl: (d['bannerImageUrl'] ?? '') as String,
      mainCategory: (d['mainCategory'] ?? '') as String,
      subCategories: List<String>.from(d['subCategories'] ?? []),
      availableDays: List<String>.from(d['availableDays'] ?? []),
      languages: List<String>.from(d['languages'] ?? []),
      serviceImages: List<String>.from(d['serviceImages'] ?? []),
      hourlyRate: ((d['hourlyRate'] ?? 0) as num).toDouble(),
      maxBookingsPerDay: (d['maxBookingsPerDay'] ?? 0) as int,
      yearsOfExperience: (d['yearsOfExperience'] ?? 0) as int,
      profileComplete: (d['profileComplete'] ?? false) as bool,
      lat: ((loc['lat'] ?? 0) as num).toDouble(),
      lng: ((loc['lng'] ?? 0) as num).toDouble(),
      address: (loc['address'] ?? '') as String,
      rating: ((d['rating'] ?? 0) as num).toDouble(),
      totalReviews: (d['totalReviews'] ?? 0) as int,
      createdAt: _toDate(d['createdAt']),
      updatedAt: _toDate(d['updatedAt']),
      fcmToken: d['fcmToken'] as String?,
    );
  }

  // ── fromMap (plain Map) ───────────────────────────────────────────────────
  factory FixerModel.fromMap(Map<String, dynamic> d) {
    final loc = d['location'] as Map<String, dynamic>? ?? {};
    return FixerModel(
      uid: (d['uid'] ?? '') as String,
      fullName: (d['fullName'] ?? '') as String,
      email: (d['email'] ?? '') as String,
      phone: (d['phone'] ?? '') as String,
      gender: (d['gender'] ?? '') as String,
      bio: (d['bio'] ?? '') as String,
      profileImageUrl: (d['profileImageUrl'] ?? '') as String,
      bannerImageUrl: (d['bannerImageUrl'] ?? '') as String,
      mainCategory: (d['mainCategory'] ?? '') as String,
      subCategories: List<String>.from(d['subCategories'] ?? []),
      availableDays: List<String>.from(d['availableDays'] ?? []),
      languages: List<String>.from(d['languages'] ?? []),
      serviceImages: List<String>.from(d['serviceImages'] ?? []),
      hourlyRate: ((d['hourlyRate'] ?? 0) as num).toDouble(),
      maxBookingsPerDay: (d['maxBookingsPerDay'] ?? 0) as int,
      yearsOfExperience: (d['yearsOfExperience'] ?? 0) as int,
      profileComplete: (d['profileComplete'] ?? false) as bool,
      lat: ((loc['lat'] ?? 0) as num).toDouble(),
      lng: ((loc['lng'] ?? 0) as num).toDouble(),
      address: (loc['address'] ?? '') as String,
      rating: ((d['rating'] ?? 0) as num).toDouble(),
      totalReviews: (d['totalReviews'] ?? 0) as int,
      createdAt: _toDate(d['createdAt']),
      updatedAt: _toDate(d['updatedAt']),
      fcmToken: d['fcmToken'] as String?,
    );
  }

  // ── toMap ─────────────────────────────────────────────────────────────────
  Map<String, dynamic> toMap() => {
    'uid': uid,
    'fullName': fullName,
    'email': email,
    'phone': phone,
    'gender': gender,
    'bio': bio,
    'profileImageUrl': profileImageUrl,
    'bannerImageUrl': bannerImageUrl,
    'mainCategory': mainCategory,
    'subCategories': subCategories,
    'availableDays': availableDays,
    'languages': languages,
    'serviceImages': serviceImages,
    'hourlyRate': hourlyRate,
    'maxBookingsPerDay': maxBookingsPerDay,
    'yearsOfExperience': yearsOfExperience,
    'profileComplete': profileComplete,
    'location': {'lat': lat, 'lng': lng, 'address': address},
    'rating': rating,
    'totalReviews': totalReviews,
    'fcmToken': fcmToken,
    'createdAt': Timestamp.fromDate(createdAt.toUtc()),
    'updatedAt': FieldValue.serverTimestamp(),
  };

  // ── copyWith ──────────────────────────────────────────────────────────────
  FixerModel copyWith({
    String? fullName,
    String? phone,
    String? gender,
    String? bio,
    String? profileImageUrl,
    String? bannerImageUrl,
    String? mainCategory,
    List<String>? subCategories,
    List<String>? availableDays,
    List<String>? languages,
    List<String>? serviceImages,
    double? hourlyRate,
    int? maxBookingsPerDay,
    int? yearsOfExperience,
    bool? profileComplete,
    double? lat,
    double? lng,
    String? address,
    double? rating,
    int? totalReviews,
    String? fcmToken,
    DateTime? updatedAt,
  }) {
    return FixerModel(
      uid: uid,
      fullName: fullName ?? this.fullName,
      email: email,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      bio: bio ?? this.bio,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bannerImageUrl: bannerImageUrl ?? this.bannerImageUrl,
      mainCategory: mainCategory ?? this.mainCategory,
      subCategories: subCategories ?? this.subCategories,
      availableDays: availableDays ?? this.availableDays,
      languages: languages ?? this.languages,
      serviceImages: serviceImages ?? this.serviceImages,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      maxBookingsPerDay: maxBookingsPerDay ?? this.maxBookingsPerDay,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      profileComplete: profileComplete ?? this.profileComplete,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      address: address ?? this.address,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ── Timestamp helper ──────────────────────────────────────────────────────
  static DateTime _toDate(dynamic value) {
    if (value == null) return DateTime.fromMillisecondsSinceEpoch(0);
    if (value is Timestamp) return value.toDate();
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}