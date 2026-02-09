import '../../core/utils/firestore_serializers.dart';
import '../enums/app_enums.dart';
import 'location_model.dart';

class JobRequestModel {
  final String id;
  final String userId;
  final String? providerId; // null => open for all
  final String category;
  final String subCategory;
  final String description;
  final List<String> images;
  final LocationModel location;
  final DateTime scheduledDate;
  final double budgetMin;
  final double budgetMax;
  final PaymentMethod paymentMethod;
  final JobStatus status;
  final DateTime createdAt;

  const JobRequestModel({
    required this.id,
    required this.userId,
    required this.providerId,
    required this.category,
    required this.subCategory,
    required this.description,
    required this.images,
    required this.location,
    required this.scheduledDate,
    required this.budgetMin,
    required this.budgetMax,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
  });

  JobRequestModel copyWith({
    String? providerId,
    String? category,
    String? subCategory,
    String? description,
    List<String>? images,
    LocationModel? location,
    DateTime? scheduledDate,
    double? budgetMin,
    double? budgetMax,
    PaymentMethod? paymentMethod,
    JobStatus? status,
  }) {
    return JobRequestModel(
      id: id,
      userId: userId,
      providerId: providerId ?? this.providerId,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      description: description ?? this.description,
      images: images ?? this.images,
      location: location ?? this.location,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      budgetMin: budgetMin ?? this.budgetMin,
      budgetMax: budgetMax ?? this.budgetMax,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'providerId': providerId,
    'category': category,
    'subCategory': subCategory,
    'description': description,
    'images': images,
    'location': location.toJson(),
    'scheduledDate': FirestoreSerializers.timestampFromDateTime(scheduledDate),
    'budgetMin': budgetMin,
    'budgetMax': budgetMax,
    'paymentMethod': enumToString(paymentMethod),
    'status': enumToString(status),
    'createdAt': FirestoreSerializers.timestampFromDateTime(createdAt),
  };

  factory JobRequestModel.fromJson(Map<String, dynamic> json) {
    return JobRequestModel(
      id: (json['id'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      providerId: json['providerId'] == null
          ? null
          : (json['providerId'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      subCategory: (json['subCategory'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      images: FirestoreSerializers.toStringList(json['images']),
      location: LocationModel.fromJson(
        FirestoreSerializers.toMap(json['location']),
      ),
      scheduledDate:
          FirestoreSerializers.dateTimeFrom(json['scheduledDate']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      budgetMin: FirestoreSerializers.toDouble(json['budgetMin']),
      budgetMax: FirestoreSerializers.toDouble(json['budgetMax']),
      paymentMethod: enumFromString<PaymentMethod>(
        PaymentMethod.values,
        (json['paymentMethod'] ?? 'card').toString(),
        PaymentMethod.card,
      ),
      status: enumFromString<JobStatus>(
        JobStatus.values,
        (json['status'] ?? 'newRequest').toString(),
        JobStatus.newRequest,
      ),
      createdAt:
          FirestoreSerializers.dateTimeFrom(json['createdAt']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
