import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:servicex_client_app/domain/models/booking_model.dart';
import 'package:servicex_client_app/domain/repos/booking_repository.dart';

class JobsTabController extends GetxController {
  final BookingRepository _repo = BookingRepository();

  final RxList<BookingModel> bookings = <BookingModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;

  StreamSubscription<List<BookingModel>>? _sub;

  @override
  void onInit() {
    super.onInit();
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isNotEmpty) _listen(uid);
  }

  void _listen(String clientId) {
    _sub?.cancel();
    _sub = _repo.watchClientBookings(clientId).listen(
          (data) {
        bookings.assignAll(data);
        isLoading.value = false;
      },
      onError: (e) {
        error.value = e.toString();
        isLoading.value = false;
      },
    );
  }

  // ── Actions ───────────────────────────────────────────────────

  Future<void> cancelBooking(String bookingId) =>
      _repo.updateStatus(bookingId, 'cancelled');

  Future<void> markComplete(String bookingId) =>
      _repo.updateStatus(bookingId, 'completed');

  Future<void> submitReview({
    required String bookingId,
    required String fixerId,
    required double rating,
    required String review,
  }) async {
    final clientId = FirebaseAuth.instance.currentUser?.uid ?? '';
    await FirebaseFirestore.instance
        .collection('bookings')
        .doc(bookingId)
        .update({
      'review': review,
      'rating': rating,
      'reviewedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await FirebaseFirestore.instance.collection('reviews').add({
      'bookingId': bookingId,
      'fixerId': fixerId,
      'clientId': clientId,
      'rating': rating,
      'review': review,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}