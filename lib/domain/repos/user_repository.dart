import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firestore_paths.dart';
import '../models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _db;
  UserRepository({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _doc(String userId) =>
      _db.collection(FirestorePaths.users).doc(userId);

  Future<void> createUser(UserModel user) async {
    await _doc(user.id).set(user.toJson(), SetOptions(merge: false));
  }

  Future<UserModel?> getUser(String userId) async {
    final snap = await _doc(userId).get();
    if (!snap.exists) return null;
    return UserModel.fromJson(snap.data()!..['id'] = snap.id);
  }

  Stream<UserModel?> watchUser(String userId) {
    return _doc(userId).snapshots().map((snap) {
      if (!snap.exists) return null;
      final data = snap.data() ?? <String, dynamic>{};
      data['id'] = snap.id;
      return UserModel.fromJson(data);
    });
  }

  Future<void> updateUser(String userId, Map<String, dynamic> patch) async {
    await _doc(userId).set(patch, SetOptions(merge: true));
  }

  Future<UserModel> getUserById(String uid) async {
    final snap = await _doc(uid).get();
    if (!snap.exists) throw Exception('User not found');

    final data = snap.data() ?? <String, dynamic>{};
    data['id'] = snap.id; // keep consistent
    return UserModel.fromJson(data);
  }

}
