// Add BookingStatus to your existing app_enums.dart:
//
// enum BookingStatus { pending, accepted, inProgress, completed, cancelled }
//
// ─────────────────────────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:servicex_client_app/domain/models/booking_model.dart';

class BookingRepository {
  final FirebaseFirestore _db;

  BookingRepository([FirebaseFirestore? db])
      : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('bookings');

  /// Creates the booking document using the pre-reserved [booking.id].
  Future<void> createBooking(BookingModel booking) =>
      _col.doc(booking.id).set(booking.toMap());

  /// Light query — fetch all bookings for a client.
  Stream<List<BookingModel>> watchClientBookings(String clientId) => _col
      .where('clientId', isEqualTo: clientId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map(BookingModel.fromDoc).toList());

  /// Light query — fetch all bookings assigned to a fixer.
  Stream<List<BookingModel>> watchFixerBookings(String fixerId) => _col
      .where('fixerId', isEqualTo: fixerId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map(BookingModel.fromDoc).toList());

  /// Single booking by ID.
  Future<BookingModel?> getBooking(String id) async {
    final doc = await _col.doc(id).get();
    return doc.exists ? BookingModel.fromDoc(doc) : null;
  }

  Future<void> updateStatus(String id, String status) =>
      _col.doc(id).update({'status': status, 'updatedAt': FieldValue.serverTimestamp()});
}