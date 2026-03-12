import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:servicex_client_app/domain/enums/app_enums.dart';

/// Firestore document stored at: bookings/{bookingId}
///
/// Denormalized fields (clientId, fixerId, categoryId, subcategoryId) are
/// stored flat so Firestore compound queries stay cheap — no joins needed.
class BookingModel {
  final String id;

  // ── Participants ──────────────────────────────────────────────
  final String clientId;
  final String fixerId;       // service provider UID
  // Denormalized at creation — zero extra reads on list screens
  final String fixerName;
  final String fixerImageUrl;

  // ── Category (denormalized for light queries) ─────────────────
  final String categoryId;
  final String categoryName;
  final String subcategoryId;
  final String subcategoryName;

  // ── Job details ───────────────────────────────────────────────
  final String details;
  final List<String> imageUrls;

  // ── Location ──────────────────────────────────────────────────
  final String address;
  final double lat;
  final double lng;

  // ── Schedule ──────────────────────────────────────────────────
  final DateTime scheduledAt;

  // ── Budget ────────────────────────────────────────────────────
  final int budgetMin;
  final int budgetMax;

  // ── Payment ───────────────────────────────────────────────────
  final String paymentMethod;

  // ── Status ────────────────────────────────────────────────────
  final BookingStatus status;

  // ── Review (written after completion) ────────────────────────
  final double? rating;
  final String? review;

  // ── Timestamps ────────────────────────────────────────────────
  final DateTime createdAt;
  final DateTime updatedAt;

  const BookingModel({
    required this.id,
    required this.clientId,
    required this.fixerId,
    required this.fixerName,
    required this.fixerImageUrl,
    required this.categoryId,
    required this.categoryName,
    required this.subcategoryId,
    required this.subcategoryName,
    required this.details,
    required this.imageUrls,
    required this.address,
    required this.lat,
    required this.lng,
    required this.scheduledAt,
    required this.budgetMin,
    required this.budgetMax,
    required this.paymentMethod,
    required this.status,
    this.rating,
    this.review,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'clientId': clientId,
    'fixerId': fixerId,
    'fixerName': fixerName,
    'fixerImageUrl': fixerImageUrl,
    'categoryId': categoryId,
    'categoryName': categoryName,
    'subcategoryId': subcategoryId,
    'subcategoryName': subcategoryName,
    'details': details,
    'imageUrls': imageUrls,
    'address': address,
    'lat': lat,
    'lng': lng,
    'scheduledAt': Timestamp.fromDate(scheduledAt),
    'budgetMin': budgetMin,
    'budgetMax': budgetMax,
    'paymentMethod': paymentMethod,
    'status': status.name,
    if (rating != null) 'rating': rating,
    if (review != null) 'review': review,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };

  factory BookingModel.fromMap(Map<String, dynamic> map) => BookingModel(
    id: map['id'] as String,
    clientId: map['clientId'] as String,
    fixerId: map['fixerId'] as String,
    fixerName: (map['fixerName'] as String?) ?? '',
    fixerImageUrl: (map['fixerImageUrl'] as String?) ?? '',
    categoryId: map['categoryId'] as String,
    categoryName: map['categoryName'] as String,
    subcategoryId: map['subcategoryId'] as String,
    subcategoryName: map['subcategoryName'] as String,
    details: map['details'] as String,
    imageUrls: List<String>.from(map['imageUrls'] ?? []),
    address: map['address'] as String,
    lat: (map['lat'] as num).toDouble(),
    lng: (map['lng'] as num).toDouble(),
    scheduledAt: (map['scheduledAt'] as Timestamp).toDate(),
    budgetMin: map['budgetMin'] as int,
    budgetMax: map['budgetMax'] as int,
    paymentMethod: map['paymentMethod'] as String,
    status: BookingStatus.values.firstWhere(
          (e) => e.name == map['status'],
      orElse: () => BookingStatus.pending,
    ),
    rating: (map['rating'] as num?)?.toDouble(),
    review: map['review'] as String?,
    createdAt: (map['createdAt'] as Timestamp).toDate(),
    updatedAt: (map['updatedAt'] as Timestamp).toDate(),
  );

  factory BookingModel.fromDoc(DocumentSnapshot doc) =>
      BookingModel.fromMap(doc.data() as Map<String, dynamic>);
}