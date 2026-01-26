import '../../core/utils/firestore_serializers.dart';

class MessageModel {
  final String id;
  final String chatRoomId;
  final String senderId;
  final String text;
  final String? mediaUrl;
  final DateTime sentAt;

  const MessageModel({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.text,
    required this.mediaUrl,
    required this.sentAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'chatRoomId': chatRoomId,
    'senderId': senderId,
    'text': text,
    'mediaUrl': mediaUrl,
    'sentAt': FirestoreSerializers.timestampFromDateTime(sentAt),
  };

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: (json['id'] ?? '').toString(),
      chatRoomId: (json['chatRoomId'] ?? '').toString(),
      senderId: (json['senderId'] ?? '').toString(),
      text: (json['text'] ?? '').toString(),
      mediaUrl: json['mediaUrl'] == null ? null : (json['mediaUrl'] ?? '').toString(),
      sentAt: FirestoreSerializers.dateTimeFrom(json['sentAt']) ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
