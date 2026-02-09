import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firestore_paths.dart';
import '../../models/booking_model.dart';

class BookingRepository {
  final FirebaseFirestore _db;
  BookingRepository({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection(FirestorePaths.bookings);

  Future<String> upsertBooking(BookingModel booking) async {
    final ref = booking.id.isEmpty ? _col.doc() : _col.doc(booking.id);
    await ref.set(booking.toJson()..['id'] = ref.id, SetOptions(merge: true));
    return ref.id;
  }

  Stream<List<BookingModel>> watchUserBookings(String userId) {
    return _col
        .where('userId', isEqualTo: userId)
        .orderBy('startTime', descending: true)
        .snapshots()
        .map((q) {
          return q.docs.map((d) {
            final data = d.data();
            data['id'] = d.id;
            return BookingModel.fromJson(data);
          }).toList();
        });
  }

  Stream<List<BookingModel>> watchProviderBookings(String providerId) {
    return _col
        .where('providerId', isEqualTo: providerId)
        .orderBy('startTime', descending: true)
        .snapshots()
        .map((q) {
          return q.docs.map((d) {
            final data = d.data();
            data['id'] = d.id;
            return BookingModel.fromJson(data);
          }).toList();
        });
  }
}
