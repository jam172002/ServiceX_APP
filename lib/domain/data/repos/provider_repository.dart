import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firestore_paths.dart';
import '../../models/provider_profile_model.dart';

class ProviderRepository {
  final FirebaseFirestore _db;
  ProviderRepository({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _doc(String providerId) =>
      _db.collection(FirestorePaths.providers).doc(providerId);

  Future<void> upsertProviderProfile(ProviderProfileModel profile) async {
    await _doc(
      profile.providerId,
    ).set(profile.toJson(), SetOptions(merge: true));
  }

  Future<ProviderProfileModel?> getProviderProfile(String providerId) async {
    final snap = await _doc(providerId).get();
    if (!snap.exists) return null;
    final data = snap.data() ?? <String, dynamic>{};
    data['providerId'] = snap.id;
    return ProviderProfileModel.fromJson(data);
  }

  Stream<ProviderProfileModel?> watchProviderProfile(String providerId) {
    return _doc(providerId).snapshots().map((snap) {
      if (!snap.exists) return null;
      final data = snap.data() ?? <String, dynamic>{};
      data['providerId'] = snap.id;
      return ProviderProfileModel.fromJson(data);
    });
  }

  Future<void> setAvailability(String providerId, bool isAvailable) async {
    await _doc(
      providerId,
    ).set({'isAvailable': isAvailable}, SetOptions(merge: true));
  }
}
