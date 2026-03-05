import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firestore_paths.dart';
import '../models/service_category.dart';

class CategoryRepository {
  final FirebaseFirestore _db;
  CategoryRepository({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection(FirestorePaths.categories);

  Future<List<ServiceCategory>> getAllCategories() async {
    final snap = await _col.get();
    return snap.docs.map((d) {
      final data = d.data();
      data['id'] = d.id;
      return ServiceCategory.fromJson(data);
    }).toList();
  }

  Stream<List<ServiceCategory>> watchAllCategories() {
    return _col.snapshots().map((q) {
      return q.docs.map((d) {
        final data = d.data();
        data['id'] = d.id;
        return ServiceCategory.fromJson(data);
      }).toList();
    });
  }
}
