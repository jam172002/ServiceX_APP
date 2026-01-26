import 'dart:async';
import 'package:get/get.dart';
import '../data/repos/provider_repository.dart';
import '../domain/models/provider_profile_model.dart';

class ProviderController extends GetxController {
  final ProviderRepository _repo;
  ProviderController({required ProviderRepository repo}) : _repo = repo;

  final Rxn<ProviderProfileModel> profile = Rxn<ProviderProfileModel>();
  StreamSubscription<ProviderProfileModel?>? _sub;

  void bindProfile(String providerId) {
    _sub?.cancel();
    _sub = _repo.watchProviderProfile(providerId).listen((p) => profile.value = p);
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }

  Future<void> upsertProfile(ProviderProfileModel p) => _repo.upsertProviderProfile(p);

  Future<void> setAvailability(String providerId, bool isAvailable) => _repo.setAvailability(providerId, isAvailable);
}
