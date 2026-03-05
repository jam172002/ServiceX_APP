import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceSubcategory {
  final String id;
  final String categoryId;
  final String name;
  final String icon;      // Firestore field is 'icon' — a key string e.g. "plumbing"
  final String imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  ServiceSubcategory({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.icon,
    required this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ServiceSubcategory.fromDoc(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return ServiceSubcategory(
      id: doc.id,
      categoryId: (d['categoryId'] ?? '') as String,
      name: (d['name'] ?? '') as String,
      icon: (d['icon'] ?? '') as String,         // ✅ 'icon' not 'iconUrl'
      imageUrl: (d['imageUrl'] ?? '') as String,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate() ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toMap() => {
    'categoryId': categoryId,
    'name': name.trim(),
    'icon': icon.trim(),
    'imageUrl': imageUrl.trim(),
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };
}