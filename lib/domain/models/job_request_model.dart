import 'package:cloud_firestore/cloud_firestore.dart';
import '../enums/app_enums.dart';

class JobRequestModel {
  final String id;
  final String userId;
  final String? providerId;       // null = open for all
  final String categoryId;
  final String categoryName;
  final String subcategoryId;
  final String subcategoryName;
  final String details;
  final String address;
  final double lat;
  final double lng;
  final DateTime scheduledAt;
  final int budgetMin;
  final int budgetMax;
  final String paymentMethod;
  final List<String> imageUrls;
  final bool isOpenForAll;
  final JobStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const JobRequestModel({
    required this.id,
    required this.userId,
    this.providerId,
    required this.categoryId,
    required this.categoryName,
    required this.subcategoryId,
    required this.subcategoryName,
    required this.details,
    required this.address,
    required this.lat,
    required this.lng,
    required this.scheduledAt,
    required this.budgetMin,
    required this.budgetMax,
    required this.paymentMethod,
    required this.imageUrls,
    required this.isOpenForAll,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  JobRequestModel copyWith({
    String? id,
    String? userId,
    String? providerId,
    String? categoryId,
    String? categoryName,
    String? subcategoryId,
    String? subcategoryName,
    String? details,
    String? address,
    double? lat,
    double? lng,
    DateTime? scheduledAt,
    int? budgetMin,
    int? budgetMax,
    String? paymentMethod,
    List<String>? imageUrls,
    bool? isOpenForAll,
    JobStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return JobRequestModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      providerId: providerId ?? this.providerId,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      subcategoryName: subcategoryName ?? this.subcategoryName,
      details: details ?? this.details,
      address: address ?? this.address,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      budgetMin: budgetMin ?? this.budgetMin,
      budgetMax: budgetMax ?? this.budgetMax,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      imageUrls: imageUrls ?? this.imageUrls,
      isOpenForAll: isOpenForAll ?? this.isOpenForAll,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'providerId': providerId,
    'categoryId': categoryId,
    'categoryName': categoryName,
    'subcategoryId': subcategoryId,
    'subcategoryName': subcategoryName,
    'details': details,
    'address': address,
    'lat': lat,
    'lng': lng,
    'scheduledAt': Timestamp.fromDate(scheduledAt),
    'budgetMin': budgetMin,
    'budgetMax': budgetMax,
    'paymentMethod': paymentMethod,
    'imageUrls': imageUrls,
    'isOpenForAll': isOpenForAll,
    'status': jobStatusToString(status),
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };

  factory JobRequestModel.fromJson(Map<String, dynamic> json) {
    return JobRequestModel(
      id: (json['id'] ?? '') as String,
      userId: (json['userId'] ?? '') as String,
      providerId: json['providerId'] as String?,
      categoryId: (json['categoryId'] ?? '') as String,
      categoryName: (json['categoryName'] ?? '') as String,
      subcategoryId: (json['subcategoryId'] ?? '') as String,
      subcategoryName: (json['subcategoryName'] ?? '') as String,
      details: (json['details'] ?? '') as String,
      address: (json['address'] ?? '') as String,
      lat: (json['lat'] ?? 0).toDouble(),
      lng: (json['lng'] ?? 0).toDouble(),
      scheduledAt: (json['scheduledAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      budgetMin: (json['budgetMin'] ?? 0) as int,
      budgetMax: (json['budgetMax'] ?? 0) as int,
      paymentMethod: (json['paymentMethod'] ?? '') as String,
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      isOpenForAll: (json['isOpenForAll'] ?? true) as bool,
      status: jobStatusFromString(json['status'] as String? ?? ''),
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }


}

// ── JobStatus helpers ─────────────────────────────────────────────
// These cover ALL enum values — no UnimplementedError, no missing cases.

String jobStatusToString(JobStatus s) {
  switch (s) {
    case JobStatus.newRequest:   return 'newRequest';
    case JobStatus.pending:      return 'pending';
    case JobStatus.underReview:  return 'underReview';
    case JobStatus.accepted:     return 'accepted';
    case JobStatus.inProgress:   return 'inProgress';
    case JobStatus.ongoing:      return 'ongoing';
    case JobStatus.completed:    return 'completed';
    case JobStatus.cancelled:    return 'cancelled';
  }
}

JobStatus jobStatusFromString(String s) {
  switch (s) {
    case 'newRequest':  return JobStatus.newRequest;
    case 'pending':     return JobStatus.pending;
    case 'underReview': return JobStatus.underReview;
    case 'accepted':    return JobStatus.accepted;
    case 'inProgress':  return JobStatus.inProgress;
    case 'ongoing':     return JobStatus.ongoing;
    case 'completed':   return JobStatus.completed;
    case 'cancelled':   return JobStatus.cancelled;
    default:            return JobStatus.pending;
  }

}