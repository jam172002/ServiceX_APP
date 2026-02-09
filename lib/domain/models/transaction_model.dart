import '../../core/utils/firestore_serializers.dart';
import '../enums/app_enums.dart';

class TransactionModel {
  final String id;
  final String walletId;
  final double amount;
  final TransactionType type;
  final TransactionStatus status;
  final DateTime createdAt;
  final String reference;

  const TransactionModel({
    required this.id,
    required this.walletId,
    required this.amount,
    required this.type,
    required this.status,
    required this.createdAt,
    required this.reference,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'walletId': walletId,
    'amount': amount,
    'type': enumToString(type),
    'status': enumToString(status),
    'createdAt': FirestoreSerializers.timestampFromDateTime(createdAt),
    'reference': reference,
  };

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: (json['id'] ?? '').toString(),
      walletId: (json['walletId'] ?? '').toString(),
      amount: FirestoreSerializers.toDouble(json['amount']),
      type: enumFromString<TransactionType>(
        TransactionType.values,
        (json['type'] ?? 'debit').toString(),
        TransactionType.debit,
      ),
      status: enumFromString<TransactionStatus>(
        TransactionStatus.values,
        (json['status'] ?? 'pending').toString(),
        TransactionStatus.pending,
      ),
      createdAt:
          FirestoreSerializers.dateTimeFrom(json['createdAt']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      reference: (json['reference'] ?? '').toString(),
    );
  }
}
