
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:servicex_client_app/domain/models/service_category.dart';

import '../models/service_subcategory.dart';

class ServiceCatalogRepo {
   final FirebaseFirestore _db;

  ServiceCatalogRepo(this._db);

   Stream<List<ServiceCategory>> watchCategories() {
     return _db
         .collection('service_categories')
         .orderBy('createdAt', descending: true)
         .snapshots()
         .map(
           (snapshot) => snapshot.docs
           .map((doc) => ServiceCategory.fromDoc(doc))
           .toList(),
     );
   }


   Stream<List<ServiceSubcategory>> watchSubcategoriesByCategory(String categoryId) {
     return _db
         .collection('service_subcategories')
         .where('categoryId', isEqualTo: categoryId)
         .orderBy('createdAt', descending: true)
         .withConverter<Map<String, dynamic>>(
       fromFirestore: (s, _) => s.data() ?? {},
       toFirestore: (m, _) => m,
     )
         .snapshots()
         .map((snap) => snap.docs.map((d) => ServiceSubcategory.fromDoc(d)).toList());
   }

   Stream<List<ServiceSubcategory>> watchAllSubcategories() {
     return _db
         .collection('service_subcategories')
         .orderBy('createdAt', descending: true)
         .withConverter<Map<String, dynamic>>(
       fromFirestore: (s, _) => s.data() ?? {},
       toFirestore: (m, _) => m,
     )
         .snapshots()
         .map((snap) => snap.docs.map((d) => ServiceSubcategory.fromDoc(d)).toList());
   }
}