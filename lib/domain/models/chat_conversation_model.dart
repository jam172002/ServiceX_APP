import 'package:cloud_firestore/cloud_firestore.dart';

class ChatConversation {
  final String id;            // "${userA_uid}_${userB_uid}" — alphabetically sorted
  final List<String> participants;
  final String lastMessage;
  final String lastMessageSenderId;
  final DateTime lastMessageTime;
  final Map<String, int> unreadCount; // { uid: count }
  final Map<String, String> participantNames;
  final Map<String, String> participantAvatars;
  final Map<String, String?> fcmTokens; // { uid: token }

  const ChatConversation({
    required this.id,
    required this.participants,
    required this.lastMessage,
    required this.lastMessageSenderId,
    required this.lastMessageTime,
    required this.unreadCount,
    required this.participantNames,
    required this.participantAvatars,
    required this.fcmTokens,
  });

  // ── Helper: build a stable conversation ID from two UIDs ──────

  static String buildId(String uid1, String uid2) {
    final sorted = [uid1, uid2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  // ── Firestore serialisation ────────────────────────────────────

  factory ChatConversation.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ChatConversation(
      id: doc.id,
      participants: List<String>.from(d['participants'] ?? []),
      lastMessage: d['lastMessage'] as String? ?? '',
      lastMessageSenderId: d['lastMessageSenderId'] as String? ?? '',
      lastMessageTime:
      (d['lastMessageTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      unreadCount: Map<String, int>.from(d['unreadCount'] ?? {}),
      participantNames: Map<String, String>.from(d['participantNames'] ?? {}),
      participantAvatars:
      Map<String, String>.from(d['participantAvatars'] ?? {}),
      fcmTokens: Map<String, String?>.from(d['fcmTokens'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'participants': participants,
    'lastMessage': lastMessage,
    'lastMessageSenderId': lastMessageSenderId,
    'lastMessageTime': Timestamp.fromDate(lastMessageTime),
    'unreadCount': unreadCount,
    'participantNames': participantNames,
    'participantAvatars': participantAvatars,
    'fcmTokens': fcmTokens,
  };

  // ── Convenience getters for the "other" participant ───────────

  String otherUserId(String myId) =>
      participants.firstWhere((p) => p != myId, orElse: () => '');

  String otherUserName(String myId) =>
      participantNames[otherUserId(myId)] ?? 'Unknown';

  String otherUserAvatar(String myId) =>
      participantAvatars[otherUserId(myId)] ?? '';

  int myUnreadCount(String myId) => unreadCount[myId] ?? 0;

  String get formattedTime {
    final now = DateTime.now();
    final diff = now.difference(lastMessageTime);
    if (diff.inDays == 0) {
      final h = lastMessageTime.hour % 12 == 0 ? 12 : lastMessageTime.hour % 12;
      final m = lastMessageTime.minute.toString().padLeft(2, '0');
      final ampm = lastMessageTime.hour >= 12 ? 'PM' : 'AM';
      return '$h:$m $ampm';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[lastMessageTime.weekday - 1];
    } else {
      return '${lastMessageTime.day}/${lastMessageTime.month}/${lastMessageTime.year}';
    }
  }
}