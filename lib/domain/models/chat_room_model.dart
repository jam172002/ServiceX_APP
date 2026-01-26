import '../../core/utils/firestore_serializers.dart';

class ChatRoomModel {
  final String id;
  final String userId;
  final String providerId;
  final DateTime lastMessageTime;

  const ChatRoomModel({
    required this.id,
    required this.userId,
    required this.providerId,
    required this.lastMessageTime,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'providerId': providerId,
    'lastMessageTime': FirestoreSerializers.timestampFromDateTime(lastMessageTime),
  };

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) {
    return ChatRoomModel(
      id: (json['id'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      providerId: (json['providerId'] ?? '').toString(),
      lastMessageTime: FirestoreSerializers.dateTimeFrom(json['lastMessageTime']) ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
