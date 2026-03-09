import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;
import '../models/chat_conversation_model.dart';
import '../models/message_model.dart';

/// Low-level Firestore / Storage access for chat.
/// Keep this class dependency-free (no GetX, no Flutter widgets).
class ChatRepository {
  ChatRepository._();
  static final ChatRepository instance = ChatRepository._();

  final _db = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  // ── Collection helpers ─────────────────────────────────────────

  CollectionReference<Map<String, dynamic>> get _conversations =>
      _db.collection('conversations');

  CollectionReference<Map<String, dynamic>> _messages(String convId) =>
      _conversations.doc(convId).collection('messages');

  // ── Conversations ──────────────────────────────────────────────

  /// Stream of all conversations for [uid], sorted newest first.
  Stream<List<ChatConversation>> conversationsStream(String uid) =>
      _conversations
          .where('participants', arrayContains: uid)
          .orderBy('lastMessageTime', descending: true)
          .snapshots()
          .map((s) => s.docs.map(ChatConversation.fromFirestore).toList());

  /// Ensure the conversation document exists; returns its ID.
  Future<String> ensureConversation({
    required String myId,
    required String otherId,
    required String myName,
    required String otherName,
    required String myAvatar,
    required String otherAvatar,
    String? myFcmToken,
    String? otherFcmToken,
  }) async {
    final convId = ChatConversation.buildId(myId, otherId);
    final ref = _conversations.doc(convId);
    final snap = await ref.get();

    if (!snap.exists) {
      await ref.set({
        'participants': [myId, otherId],
        'lastMessage': '',
        'lastMessageSenderId': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'unreadCount': {myId: 0, otherId: 0},
        'participantNames': {myId: myName, otherId: otherName},
        'participantAvatars': {myId: myAvatar, otherId: otherAvatar},
        'fcmTokens': {
          myId: myFcmToken,
          otherId: otherFcmToken,
        },
      });
    } else {
      // Keep FCM tokens fresh
      await ref.update({
        'fcmTokens.$myId': myFcmToken,
        'participantNames.$myId': myName,
        'participantAvatars.$myId': myAvatar,
      });
    }
    return convId;
  }

  // ── Messages ───────────────────────────────────────────────────

  /// Real-time stream of messages for a conversation.
  Stream<List<ChatMessage>> messagesStream(String convId) =>
      _messages(convId)
          .orderBy('createdAt', descending: false)
          .snapshots()
          .map((s) => s.docs.map(ChatMessage.fromFirestore).toList());

  /// Send a text message.
  Future<void> sendTextMessage({
    required String convId,
    required String senderId,
    required String receiverId,
    required String text,
  }) async {
    assert(receiverId.isNotEmpty, 'receiverId must not be empty');

    final batch = _db.batch();
    final msgRef = _messages(convId).doc();
    final convRef = _conversations.doc(convId);

    batch.set(msgRef, {
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'type': 'text',
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
    });

    batch.update(convRef, {
      'lastMessage': text,
      'lastMessageSenderId': senderId,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'unreadCount.$receiverId': FieldValue.increment(1),
    });

    await batch.commit();
  }

  /// Upload media file then send the message.
  /// Returns the download URL.
  Future<String> sendMediaMessage({
    required String convId,
    required String senderId,
    required String receiverId,
    required File file,
    required MessageType type,
  }) async {
    // 1. Upload to Firebase Storage
    final ext = p.extension(file.path);
    final folder = type == MessageType.image ? 'images' : 'videos';
    final ref = _storage.ref(
        'chat_media/$convId/$folder/${DateTime.now().millisecondsSinceEpoch}$ext');
    await ref.putFile(file);
    final url = await ref.getDownloadURL();

    // 2. Write message + update conversation
    final batch = _db.batch();
    final msgRef = _messages(convId).doc();
    final convRef = _conversations.doc(convId);

    batch.set(msgRef, {
      'senderId': senderId,
      'receiverId': receiverId,
      'text': type == MessageType.image ? '📷 Photo' : '🎥 Video',
      'type': type.name,
      'mediaUrl': url,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
    });

    batch.update(convRef, {
      'lastMessage': type == MessageType.image ? '📷 Photo' : '🎥 Video',
      'lastMessageSenderId': senderId,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'unreadCount.$receiverId': FieldValue.increment(1),
    });

    await batch.commit();
    return url;
  }

  /// Mark all messages in [convId] as read for [myId].
  Future<void> markAsRead(String convId, String myId) async {
    // Reset unread counter
    await _conversations.doc(convId).update({'unreadCount.$myId': 0});

    // Mark individual messages (batch in groups of 500)
    final unread = await _messages(convId)
        .where('receiverId', isEqualTo: myId)
        .where('isRead', isEqualTo: false)
        .get();

    if (unread.docs.isEmpty) return;

    var batch = _db.batch();
    int i = 0;
    for (final doc in unread.docs) {
      batch.update(doc.reference, {'isRead': true});
      i++;
      if (i == 500) {
        await batch.commit();
        batch = _db.batch();
        i = 0;
      }
    }
    if (i > 0) await batch.commit();
  }

  /// Delete all messages in a conversation (soft delete for current user).
  Future<void> deleteConversation(String convId, String myId) =>
      _conversations.doc(convId).update({
        'deletedBy.$myId': true,
        'lastMessage': '',
      });

  // ── FCM token update ───────────────────────────────────────────

  Future<void> updateFcmToken(String convId, String uid, String token) =>
      _conversations.doc(convId).update({'fcmTokens.$uid': token});
}