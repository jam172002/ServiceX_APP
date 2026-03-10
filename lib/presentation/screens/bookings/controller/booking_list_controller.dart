import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../../../domain/models/booking_model.dart';
import '../../../../domain/repos/booking_repository.dart';

class BookingListController extends GetxController {
  final BookingRepository _repo;
  BookingListController({required BookingRepository repo}) : _repo = repo;

  final RxList<BookingModel> userBookings = <BookingModel>[].obs;

  StreamSubscription<List<BookingModel>>? _userSub;

  @override
  void onInit() {
    super.onInit();
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isNotEmpty) bindUserBookings(uid);
  }

  void bindUserBookings(String clientId) {
    _userSub?.cancel();
    _userSub = _repo
        .watchClientBookings(clientId)
        .listen(userBookings.assignAll);
  }

  @override
  void onClose() {
    _userSub?.cancel();
    super.onClose();
  }
}