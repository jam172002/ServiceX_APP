import 'package:cloud_firestore/cloud_firestore.dart';

enum QuoteStatus { pending, accepted, rejected }

QuoteStatus quoteStatusFromString(String s) {
  switch (s) {
    case 'accepted': return QuoteStatus.accepted;
    case 'rejected': return QuoteStatus.rejected;
    default:         return QuoteStatus.pending;
  }
}

String quoteStatusToString(QuoteStatus s) {
  switch (s) {
    case QuoteStatus.accepted: return 'accepted';
    case QuoteStatus.rejected: return 'rejected';
    case QuoteStatus.pending:  return 'pending';
  }
}

class QuoteModel {
  final String id;          // fixxerId (also the doc id)
  final String jobId;
  final String fixxerId;
  final String price;
  final DateTime arrivalAt;
  final int arrivalHour;
  final int arrivalMinute;
  final String note;
  final QuoteStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  // ── Fixxer profile fields (fetched separately, not in Firestore doc) ───
  String fixxerName;
  String fixxerAvatar;
  String fixxerFcmToken;

  QuoteModel({
    required this.id,
    required this.jobId,
    required this.fixxerId,
    required this.price,
    required this.arrivalAt,
    required this.arrivalHour,
    required this.arrivalMinute,
    required this.note,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.fixxerName    = '',
    this.fixxerAvatar  = '',
    this.fixxerFcmToken= '',
  });

  factory QuoteModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return QuoteModel(
      id:            doc.id,
      jobId:         d['jobId']      as String? ?? '',
      fixxerId:      d['fixxerId']   as String? ?? doc.id,
      price:         d['price']      as String? ?? '0',
      arrivalAt:     (d['arrivalAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      arrivalHour:   d['arrivalHour']   as int? ?? 9,
      arrivalMinute: d['arrivalMinute'] as int? ?? 0,
      note:          d['note']       as String? ?? '',
      status:        quoteStatusFromString(d['status'] as String? ?? ''),
      createdAt:     (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt:     (d['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id':            id,
    'jobId':         jobId,
    'fixxerId':      fixxerId,
    'price':         price,
    'arrivalAt':     Timestamp.fromDate(arrivalAt),
    'arrivalHour':   arrivalHour,
    'arrivalMinute': arrivalMinute,
    'note':          note,
    'status':        quoteStatusToString(status),
    'createdAt':     Timestamp.fromDate(createdAt),
    'updatedAt':     Timestamp.fromDate(updatedAt),
  };

  QuoteModel copyWith({QuoteStatus? status}) => QuoteModel(
    id:             id,
    jobId:          jobId,
    fixxerId:       fixxerId,
    price:          price,
    arrivalAt:      arrivalAt,
    arrivalHour:    arrivalHour,
    arrivalMinute:  arrivalMinute,
    note:           note,
    status:         status ?? this.status,
    createdAt:      createdAt,
    updatedAt:      updatedAt,
    fixxerName:     fixxerName,
    fixxerAvatar:   fixxerAvatar,
    fixxerFcmToken: fixxerFcmToken,
  );
}