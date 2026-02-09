import 'dart:async';
import 'package:get/get.dart';
import '../../domain/data/repos/booking_repository.dart';
import '../../domain/models/booking_model.dart';

class BookingController extends GetxController {
  final BookingRepository _repo;
  BookingController({required BookingRepository repo}) : _repo = repo;

  final RxList<BookingModel> userBookings = <BookingModel>[].obs;
  final RxList<BookingModel> providerBookings = <BookingModel>[].obs;

  StreamSubscription<List<BookingModel>>? _userSub;
  StreamSubscription<List<BookingModel>>? _providerSub;

  void bindUserBookings(String userId) {
    _userSub?.cancel();
    _userSub = _repo.watchUserBookings(userId).listen(userBookings.assignAll);
  }

  void bindProviderBookings(String providerId) {
    _providerSub?.cancel();
    _providerSub = _repo
        .watchProviderBookings(providerId)
        .listen(providerBookings.assignAll);
  }

  @override
  void onClose() {
    _userSub?.cancel();
    _providerSub?.cancel();
    super.onClose();
  }
}
