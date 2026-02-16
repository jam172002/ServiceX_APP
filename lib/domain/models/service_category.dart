import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceCategory {
  final String id;
  final String name;
  final String iconUrl; // store icon key string e.g. "plumbing"
  final String imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  ServiceCategory({
    required this.id,
    required this.name,
    required this.iconUrl,
    required this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ServiceCategory.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return ServiceCategory(
      id: doc.id,
      name: (d['name'] ?? '') as String,
      iconUrl: (d['iconUrl'] ?? '') as String,
      imageUrl: (d['imageUrl'] ?? '') as String,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name.trim(),
    'iconUrl': iconUrl.trim(),
    'imageUrl': imageUrl.trim(),
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };
}