import '../../core/utils/firestore_serializers.dart';
import '../enums/app_enums.dart';

class BookingModel {
  final String id;
  final String jobRequestId;
  final String userId;
  final String providerId;
  final DateTime startTime;
  final DateTime endTime;
  final double price;
  final BookingStatus status;

  const BookingModel({
    required this.id,
    required this.jobRequestId,
    required this.userId,
    required this.providerId,
    required this.startTime,
    required this.endTime,
    required this.price,
    required this.status,
  });

  BookingModel copyWith({
    DateTime? startTime,
    DateTime? endTime,
    double? price,
    BookingStatus? status,
  }) {
    return BookingModel(
      id: id,
      jobRequestId: jobRequestId,
      userId: userId,
      providerId: providerId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      price: price ?? this.price,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'jobRequestId': jobRequestId,
    'userId': userId,
    'providerId': providerId,
    'startTime': FirestoreSerializers.timestampFromDateTime(startTime),
    'endTime': FirestoreSerializers.timestampFromDateTime(endTime),
    'price': price,
    'status': enumToString(status),
  };

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: (json['id'] ?? '').toString(),
      jobRequestId: (json['jobRequestId'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      providerId: (json['providerId'] ?? '').toString(),
      startTime:
          FirestoreSerializers.dateTimeFrom(json['startTime']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      endTime:
          FirestoreSerializers.dateTimeFrom(json['endTime']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      price: FirestoreSerializers.toDouble(json['price']),
      status: enumFromString<BookingStatus>(
        BookingStatus.values,
        (json['status'] ?? 'pending').toString(),
        BookingStatus.pending,
      ),
    );
  }
}
