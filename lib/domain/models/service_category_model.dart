import '../../core/utils/firestore_serializers.dart';

class ServiceCategoryModel {
  final String id;
  final String name;
  final String iconUrl;
  final List<String> subCategories;

  const ServiceCategoryModel({
    required this.id,
    required this.name,
    required this.iconUrl,
    required this.subCategories,
  });

  ServiceCategoryModel copyWith({
    String? name,
    String? iconUrl,
    List<String>? subCategories,
  }) {
    return ServiceCategoryModel(
      id: id,
      name: name ?? this.name,
      iconUrl: iconUrl ?? this.iconUrl,
      subCategories: subCategories ?? this.subCategories,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'iconUrl': iconUrl,
    'subCategories': subCategories,
  };

  factory ServiceCategoryModel.fromJson(Map<String, dynamic> json) {
    return ServiceCategoryModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      iconUrl: (json['iconUrl'] ?? '').toString(),
      subCategories: FirestoreSerializers.toStringList(json['subCategories']),
    );
  }
}
