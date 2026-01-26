import '../../core/utils/firestore_serializers.dart';

class ProviderProfileModel {
  final String providerId;
  final List<String> categories;
  final List<String> subCategories;
  final double hourlyRate;
  final String bio;
  final double rating;
  final int reviewCount;
  final List<String> galleryImages;
  final bool isAvailable;

  const ProviderProfileModel({
    required this.providerId,
    required this.categories,
    required this.subCategories,
    required this.hourlyRate,
    required this.bio,
    required this.rating,
    required this.reviewCount,
    required this.galleryImages,
    required this.isAvailable,
  });

  ProviderProfileModel copyWith({
    List<String>? categories,
    List<String>? subCategories,
    double? hourlyRate,
    String? bio,
    double? rating,
    int? reviewCount,
    List<String>? galleryImages,
    bool? isAvailable,
  }) {
    return ProviderProfileModel(
      providerId: providerId,
      categories: categories ?? this.categories,
      subCategories: subCategories ?? this.subCategories,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      bio: bio ?? this.bio,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      galleryImages: galleryImages ?? this.galleryImages,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  Map<String, dynamic> toJson() => {
    'providerId': providerId,
    'categories': categories,
    'subCategories': subCategories,
    'hourlyRate': hourlyRate,
    'bio': bio,
    'rating': rating,
    'reviewCount': reviewCount,
    'galleryImages': galleryImages,
    'isAvailable': isAvailable,
  };

  factory ProviderProfileModel.fromJson(Map<String, dynamic> json) {
    return ProviderProfileModel(
      providerId: (json['providerId'] ?? '').toString(),
      categories: FirestoreSerializers.toStringList(json['categories']),
      subCategories: FirestoreSerializers.toStringList(json['subCategories']),
      hourlyRate: FirestoreSerializers.toDouble(json['hourlyRate']),
      bio: (json['bio'] ?? '').toString(),
      rating: FirestoreSerializers.toDouble(json['rating']),
      reviewCount: FirestoreSerializers.toInt(json['reviewCount']),
      galleryImages: FirestoreSerializers.toStringList(json['galleryImages']),
      isAvailable: (json['isAvailable'] as bool?) ?? true,
    );
  }
}
