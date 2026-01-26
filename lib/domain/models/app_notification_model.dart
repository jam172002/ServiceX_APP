import '../../core/utils/firestore_serializers.dart';
import '../enums/app_enums.dart';

class AppNotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final NotificationType type;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic> data; // deep link payload

  const AppNotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.createdAt,
    required this.data,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'title': title,
    'body': body,
    'type': enumToString(type),
    'isRead': isRead,
    'createdAt': FirestoreSerializers.timestampFromDateTime(createdAt),
    'data': data,
  };

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) {
    return AppNotificationModel(
      id: (json['id'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      body: (json['body'] ?? '').toString(),
      type: enumFromString<NotificationType>(
        NotificationType.values,
        (json['type'] ?? 'serviceUpdate').toString(),
        NotificationType.serviceUpdate,
      ),
      isRead: (json['isRead'] as bool?) ?? false,
      createdAt: FirestoreSerializers.dateTimeFrom(json['createdAt']) ?? DateTime.fromMillisecondsSinceEpoch(0),
      data: FirestoreSerializers.toMap(json['data']),
    );
  }
}
