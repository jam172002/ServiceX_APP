import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:servicex_client_app/domain/enums/app_enums.dart';
import 'package:servicex_client_app/domain/models/booking_model.dart';
import 'package:servicex_client_app/domain/repos/booking_repository.dart';

class BookingTabController extends GetxController {
  final BookingRepository _repo;

  BookingTabController({BookingRepository? repo})
      : _repo = repo ?? BookingRepository();

  // ── State ──────────────────────────────────────────────────────────────────
  final RxList<BookingModel> bookings = <BookingModel>[].obs;
  final RxString selectedStatus = 'All'.obs;
  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;

  StreamSubscription<List<BookingModel>>? _sub;

  // ── Filter labels ──────────────────────────────────────────────────────────
  static const List<String> filterLabels = [
    'All',
    'Pending',
    'Accepted',
    'In Progress',
    'Completed',
    'Cancelled',
  ];

  // ── Filtered list ──────────────────────────────────────────────────────────
  List<BookingModel> get filteredBookings {
    if (selectedStatus.value == 'All') return bookings;
    final target = _labelToStatus(selectedStatus.value);
    if (target == null) return bookings;
    return bookings.where((b) => b.status == target).toList();
  }

  BookingStatus? _labelToStatus(String label) {
    switch (label) {
      case 'Pending':     return BookingStatus.pending;
      case 'Accepted':    return BookingStatus.accepted;
      case 'In Progress': return BookingStatus.inProgress;
      case 'Completed':   return BookingStatus.completed;
      case 'Cancelled':   return BookingStatus.cancelled;
      default:            return null;
    }
  }

  // ── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _startListening();
  }

  void _startListening() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      error.value = 'Not logged in';
      isLoading.value = false;
      return;
    }

    isLoading.value = true;
    error.value = '';

    _sub = _repo.watchClientBookings(uid).listen(
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

  void setFilter(String status) => selectedStatus.value = status;

  Future<void> refresh() async {
    await _sub?.cancel();
    _startListening();
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  Future<void> cancelBooking(String bookingId) async {
    try {
      await _repo.updateStatus(bookingId, BookingStatus.cancelled.name);
    } catch (e) {
      Get.snackbar('Error', 'Failed to cancel booking: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> markComplete(String bookingId) async {
    try {
      await _repo.updateStatus(bookingId, BookingStatus.completed.name);
    } catch (e) {
      Get.snackbar('Error', 'Failed to update booking: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> submitReview({
    required String bookingId,
    required String fixerId,
    required double rating,
    required String review,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .update({
        'rating': rating,
        'review': review,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final fixerRef =
      FirebaseFirestore.instance.collection('fixxers').doc(fixerId);

      await FirebaseFirestore.instance.runTransaction((tx) async {
        final snap = await tx.get(fixerRef);
        if (!snap.exists) return;
        final data = snap.data()!;
        final currentRating = (data['rating'] as num?)?.toDouble() ?? 0.0;
        final totalReviews = (data['totalReviews'] as num?)?.toInt() ?? 0;
        final newTotal = totalReviews + 1;
        final newRating =
            ((currentRating * totalReviews) + rating) / newTotal;
        tx.update(fixerRef, {
          'rating': double.parse(newRating.toStringAsFixed(1)),
          'totalReviews': newTotal,
        });
      });
    } catch (e) {
      Get.snackbar('Error', 'Failed to submit review: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }

  // ── Label helpers ──────────────────────────────────────────────────────────

  static String statusLabel(BookingStatus s) {
    switch (s) {
      case BookingStatus.pending:    return 'Pending';
      case BookingStatus.accepted:   return 'Accepted';
      case BookingStatus.inProgress: return 'In Progress';
      case BookingStatus.completed:  return 'Completed';
      case BookingStatus.cancelled:  return 'Cancelled';
      case BookingStatus.booked:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  static String budgetLabel(int min, int max) => 'PKR $min – $max';

  static String dateLabel(DateTime dt) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${dt.day} ${months[dt.month]} ${dt.year}';
  }

  static String timeLabel(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $period';
  }
}