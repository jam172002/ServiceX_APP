import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:servicex_client_app/domain/models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _db;
  final FirebaseStorage _storage;

  UserRepository({
    FirebaseFirestore? db,
    FirebaseStorage? storage,
  })  : _db = db ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  /// Fetch a single user by UID
  Future<UserModel?> getUserById(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) return null;
    final data = doc.data()!;
    data['id'] = doc.id;
    return UserModel.fromJson(data);
  }

  /// Create a new user document
  Future<void> createUser(UserModel user) async {
    await _users.doc(user.id).set(user.toJson());
  }

  /// Update specific fields on a user document
  Future<void> updateUser(String uid, Map<String, dynamic> fields) async {
    await _users.doc(uid).update(fields);
  }

  /// Upload profile photo to Firebase Storage and return download URL
  Future<String> uploadProfilePhoto({
    required String uid,
    required File file,
  }) async {
    final ref = _storage
        .ref()
        .child('users/$uid/profile.jpg');
    final task = await ref.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return await task.ref.getDownloadURL();
  }

  /// Fetch booking stats counts for a user
  Future<Map<String, int>> getBookingStats(String uid) async {
    final snap = await _db
        .collection('bookings')
        .where('userId', isEqualTo: uid)
        .get();

    int newCount = 0, active = 0, completed = 0, cancelled = 0;

    for (final doc in snap.docs) {
      final status =
      ((doc.data()['status'] ?? '') as String).toLowerCase();
      switch (status) {
        case 'new':
        case 'pending':
        case 'confirmed':
          newCount++;
          break;
        case 'active':
        case 'in_progress':
          active++;
          break;
        case 'completed':
          completed++;
          break;
        case 'cancelled':
          cancelled++;
          break;
      }
    }

    return {
      'new': newCount,
      'active': active,
      'completed': completed,
      'cancelled': cancelled,
    };
  }
}