import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreSerializers {
  FirestoreSerializers._();

  static DateTime? dateTimeFrom(dynamic v) {
    if (v == null) return null;
    if (v is Timestamp) return v.toDate();
    if (v is DateTime) return v;
    if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
    if (v is String) return DateTime.tryParse(v);
    return null;
  }

  static Timestamp? timestampFromDateTime(DateTime? dt) {
    if (dt == null) return null;
    return Timestamp.fromDate(dt);
  }

  static double toDouble(dynamic v, {double fallback = 0}) {
    if (v == null) return fallback;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? fallback;
    return fallback;
  }

  static int toInt(dynamic v, {int fallback = 0}) {
    if (v == null) return fallback;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? fallback;
    return fallback;
  }

  static List<String> toStringList(dynamic v) {
    if (v == null) return <String>[];
    if (v is List) {
      return v.map((e) => e.toString()).toList();
    }
    return <String>[];
  }

  static Map<String, dynamic> toMap(dynamic v) {
    if (v == null) return <String, dynamic>{};
    if (v is Map<String, dynamic>) return v;
    if (v is Map) return v.map((k, val) => MapEntry(k.toString(), val));
    return <String, dynamic>{};
  }
}
