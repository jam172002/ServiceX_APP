import 'package:cloud_firestore/cloud_firestore.dart';

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
  final double hourlyRate;
  final int maxBookingsPerDay;
  final int yearsOfExperience;
  final bool profileComplete;
  final double lat;
  final double lng;
  final String address;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? fcmToken; // <-- promoted from stub getter to real field

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
    this.fcmToken, // nullable — absent in old documents is fine
  });

  factory FixerModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    final location = d['location'] as Map<String, dynamic>? ?? {};
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
      hourlyRate: ((d['hourlyRate'] ?? 0) as num).toDouble(),
      maxBookingsPerDay: (d['maxBookingsPerDay'] ?? 0) as int,
      yearsOfExperience: (d['yearsOfExperience'] ?? 0) as int,
      profileComplete: (d['profileComplete'] ?? false) as bool,
      lat: ((location['lat'] ?? 0) as num).toDouble(),
      lng: ((location['lng'] ?? 0) as num).toDouble(),
      address: (location['address'] ?? '') as String,
      createdAt: _toDate(d['createdAt']),
      updatedAt: _toDate(d['updatedAt']),
      fcmToken: d['fcmToken'] as String?, // null-safe — missing field → null
    );
  }

  /// Handles Firestore Timestamp, int (milliseconds), and null safely.
  static DateTime _toDate(dynamic value) {
    if (value == null) return DateTime.fromMillisecondsSinceEpoch(0);
    if (value is Timestamp) return value.toDate();
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}