import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:servicex_client_app/core/constants/firestore_paths.dart';
import 'package:servicex_client_app/domain/models/app_notification_model.dart';

class NotificationRepository {
  final FirebaseFirestore _db;
  NotificationRepository({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection(FirestorePaths.notifications);

  Stream<List<AppNotificationModel>> watchUserNotifications(
    String userId, {
    int limit = 200,
  }) {
    return _col
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((q) {
          return q.docs.map((d) {
            final data = d.data();
            data['id'] = d.id;
            return AppNotificationModel.fromJson(data);
          }).toList();
        });
  }

  Future<void> markAsRead(String notificationId) async {
    await _col.doc(notificationId).set({
      'isRead': true,
    }, SetOptions(merge: true));
  }

  Future<String> createNotification(AppNotificationModel n) async {
    final ref = _col.doc(n.id.isEmpty ? null : n.id);
    final docRef = n.id.isEmpty ? _col.doc() : _col.doc(n.id);
    final payload = n.toJson()..['id'] = docRef.id;
    await docRef.set(payload, SetOptions(merge: true));
    return docRef.id;
  }
}
