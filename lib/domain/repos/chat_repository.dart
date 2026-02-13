import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firestore_paths.dart';
import '../models/chat_room_model.dart';
import '../models/message_model.dart';

class ChatRepository {
  final FirebaseFirestore _db;
  ChatRepository({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _rooms =>
      _db.collection(FirestorePaths.chatRooms);

  Future<String> createOrGetRoom({
    required String userId,
    required String providerId,
  }) async {
    final query = await _rooms
        .where('userId', isEqualTo: userId)
        .where('providerId', isEqualTo: providerId)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) return query.docs.first.id;

    final ref = _rooms.doc();
    final room = ChatRoomModel(
      id: ref.id,
      userId: userId,
      providerId: providerId,
      lastMessageTime: DateTime.now(),
    );
    await ref.set(room.toJson(), SetOptions(merge: true));
    return ref.id;
  }

  Stream<List<ChatRoomModel>> watchUserRooms(String userId) {
    return _rooms
        .where('userId', isEqualTo: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((q) {
          return q.docs.map((d) {
            final data = d.data();
            data['id'] = d.id;
            return ChatRoomModel.fromJson(data);
          }).toList();
        });
  }

  Stream<List<ChatRoomModel>> watchProviderRooms(String providerId) {
    return _rooms
        .where('providerId', isEqualTo: providerId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((q) {
          return q.docs.map((d) {
            final data = d.data();
            data['id'] = d.id;
            return ChatRoomModel.fromJson(data);
          }).toList();
        });
  }

  Future<void> sendMessage({
    required String roomId,
    required MessageModel message,
  }) async {
    final msgRef = _db
        .collection(FirestorePaths.chatRoomMessagesCol(roomId))
        .doc(message.id.isEmpty ? null : message.id);
    final ref = message.id.isEmpty
        ? _db.collection(FirestorePaths.chatRoomMessagesCol(roomId)).doc()
        : _db
              .collection(FirestorePaths.chatRoomMessagesCol(roomId))
              .doc(message.id);

    final msg = MessageModel(
      id: ref.id,
      chatRoomId: roomId,
      senderId: message.senderId,
      text: message.text,
      mediaUrl: message.mediaUrl,
      sentAt: message.sentAt,
    );

    await ref.set(msg.toJson(), SetOptions(merge: true));
    await _rooms.doc(roomId).set({
      'lastMessageTime': Timestamp.fromDate(msg.sentAt),
    }, SetOptions(merge: true));
  }

  Stream<List<MessageModel>> watchMessages(String roomId, {int limit = 100}) {
    final col = _db.collection(FirestorePaths.chatRoomMessagesCol(roomId));
    return col.orderBy('sentAt', descending: true).limit(limit).snapshots().map(
      (q) {
        return q.docs.map((d) {
          final data = d.data();
          data['id'] = d.id;
          return MessageModel.fromJson(data);
        }).toList();
      },
    );
  }

  Future<void> clearChat(String roomId) async {
    final col = _db.collection(FirestorePaths.chatRoomMessagesCol(roomId));
    final batch = _db.batch();
    final snap = await col.get();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
