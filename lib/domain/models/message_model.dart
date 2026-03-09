import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { text, image, video }

class ChatMessage {
  final String id;
  final String senderId;
  final String receiverId;
  final String text;
  final MessageType type;
  final String? mediaUrl;   // remote URL after upload
  final String? localPath;  // local path before upload
  final DateTime createdAt;
  final bool isRead;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.type,
    this.mediaUrl,
    this.localPath,
    required this.createdAt,
    this.isRead = false,
  });

  // ── Firestore serialisation ────────────────────────────────────

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      senderId: d['senderId'] as String? ?? '',
      receiverId: d['receiverId'] as String? ?? '',
      text: d['text'] as String? ?? '',
      type: MessageType.values.firstWhere(
            (e) => e.name == (d['type'] as String? ?? 'text'),
        orElse: () => MessageType.text,
      ),
      mediaUrl: d['mediaUrl'] as String?,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: d['isRead'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'senderId': senderId,
    'receiverId': receiverId,
    'text': text,
    'type': type.name,
    if (mediaUrl != null) 'mediaUrl': mediaUrl,
    'createdAt': Timestamp.fromDate(createdAt),
    'isRead': isRead,
  };

  ChatMessage copyWith({bool? isRead, String? mediaUrl}) => ChatMessage(
    id: id,
    senderId: senderId,
    receiverId: receiverId,
    text: text,
    type: type,
    mediaUrl: mediaUrl ?? this.mediaUrl,
    localPath: localPath,
    createdAt: createdAt,
    isRead: isRead ?? this.isRead,
  );
}