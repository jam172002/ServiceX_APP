import 'package:cloud_firestore/cloud_firestore.dart';
import 'fixxer_location.dart';

// Safe parser — handles Timestamp (Firestore), int (legacy millis), String (ISO)
DateTime _parseDateTime(dynamic value) {
  if (value is Timestamp) return value.toDate().toLocal();
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value, isUtc: true).toLocal();
  if (value is String) return DateTime.tryParse(value)?.toLocal() ?? DateTime.now();
  return DateTime.now();
}

class FixxerUser {
  final String uid;
  final String fullName;
  final String email;
  final String phone;
  final String gender;

  final FixxerLocation location;

  final bool profileComplete;
  final String? profileImageUrl;
  final String? bannerImageUrl;

  final String? mainCategory;
  final List<String> subCategories;
  final double? hourlyRate;
  final int? maxBookingsPerDay;
  final List<String> languages;
  final List<String> availableDays;
  final String? bio;
  final List<String> serviceImages;

  // ── Rating ───────────────────────────────────────────────────────────────
  final double rating;
  final int totalReviews;

  // ── Connects / Plan ──────────────────────────────────────────────────────
  final int connectsBalance;
  final String? activePlan;

  final DateTime createdAt;
  final DateTime updatedAt;

  const FixxerUser({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.gender,
    required this.location,
    required this.profileComplete,
    required this.subCategories,
    required this.createdAt,
    required this.updatedAt,
    this.profileImageUrl,
    this.bannerImageUrl,
    this.mainCategory,
    this.hourlyRate,
    this.maxBookingsPerDay,
    this.languages = const [],
    this.availableDays = const [],
    this.bio,
    this.serviceImages = const [],
    this.rating = 0.0,
    this.totalReviews = 0,
    this.connectsBalance = 0,
    this.activePlan,
  });

  FixxerUser copyWith({
    String? fullName,
    String? phone,
    String? gender,
    FixxerLocation? location,
    bool? profileComplete,
    String? profileImageUrl,
    String? bannerImageUrl,
    String? mainCategory,
    List<String>? subCategories,
    double? hourlyRate,
    int? maxBookingsPerDay,
    List<String>? languages,
    List<String>? availableDays,
    String? bio,
    List<String>? serviceImages,
    double? rating,
    int? totalReviews,
    int? connectsBalance,
    String? activePlan,
    DateTime? updatedAt,
  }) {
    return FixxerUser(
      uid: uid,
      fullName: fullName ?? this.fullName,
      email: email,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      location: location ?? this.location,
      profileComplete: profileComplete ?? this.profileComplete,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bannerImageUrl: bannerImageUrl ?? this.bannerImageUrl,
      mainCategory: mainCategory ?? this.mainCategory,
      subCategories: subCategories ?? this.subCategories,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      maxBookingsPerDay: maxBookingsPerDay ?? this.maxBookingsPerDay,
      languages: languages ?? this.languages,
      availableDays: availableDays ?? this.availableDays,
      bio: bio ?? this.bio,
      serviceImages: serviceImages ?? this.serviceImages,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      connectsBalance: connectsBalance ?? this.connectsBalance,
      activePlan: activePlan ?? this.activePlan,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'fullName': fullName,
    'email': email,
    'phone': phone,
    'gender': gender,
    'location': location.toMap(),
    'profileComplete': profileComplete,
    'profileImageUrl': profileImageUrl,
    'bannerImageUrl': bannerImageUrl,
    'mainCategory': mainCategory,
    'subCategories': subCategories,
    'hourlyRate': hourlyRate,
    'maxBookingsPerDay': maxBookingsPerDay,
    'languages': languages,
    'availableDays': availableDays,
    'bio': bio,
    'serviceImages': serviceImages,
    'rating': rating,
    'totalReviews': totalReviews,
    'connectsBalance': connectsBalance,
    'activePlan': activePlan,
    'createdAt': Timestamp.fromDate(createdAt.toUtc()),
    'updatedAt': FieldValue.serverTimestamp(),
  };

  factory FixxerUser.fromMap(Map<String, dynamic> map) => FixxerUser(
    uid:              (map['uid']            ?? '') as String,
    fullName:         (map['fullName']        ?? '') as String,
    email:            (map['email']           ?? '') as String,
    phone:            (map['phone']           ?? '') as String,
    gender:           (map['gender']          ?? '') as String,
    location: FixxerLocation.fromMap(
      (map['location'] ?? const <String, dynamic>{}) as Map<String, dynamic>,
    ),
    profileComplete:   (map['profileComplete']  ?? false) as bool,
    profileImageUrl:    map['profileImageUrl']  as String?,
    bannerImageUrl:     map['bannerImageUrl']   as String?,
    mainCategory:       map['mainCategory']     as String?,
    subCategories:  List<String>.from((map['subCategories']  ?? const []) as List),
    hourlyRate:     map['hourlyRate'] == null ? null : (map['hourlyRate'] as num).toDouble(),
    maxBookingsPerDay:  map['maxBookingsPerDay'] as int?,
    languages:      List<String>.from((map['languages']      ?? const []) as List),
    availableDays:  List<String>.from((map['availableDays']  ?? const []) as List),
    bio:                map['bio']             as String?,
    serviceImages:  List<String>.from((map['serviceImages']  ?? const []) as List),
    rating:         (map['rating']       as num?)?.toDouble() ?? 0.0,
    totalReviews:   (map['totalReviews'] as num?)?.toInt()    ?? 0,
    connectsBalance: (map['connectsBalance'] as num?)?.toInt() ?? 0,
    activePlan:      map['activePlan'] as String?,
    createdAt: _parseDateTime(map['createdAt']),
    updatedAt: _parseDateTime(map['updatedAt']),
  );
}