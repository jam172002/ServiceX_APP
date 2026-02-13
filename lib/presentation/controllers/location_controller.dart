import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../domain/models/location_model.dart';

class LocationController extends GetxController {
  final GetStorage _storage;
  LocationController({GetStorage? storage}) : _storage = storage ?? GetStorage();

  static const _kLoc1 = 'saved_location_1';
  static const _kLoc2 = 'saved_location_2';
  static const _kDefaultLoc = 'default_location';

  final Rxn<LocationModel> currentLocation = Rxn<LocationModel>();

  bool _close(double a, double b, [double eps = 0.00001]) => (a - b).abs() < eps;

  bool _same(LocationModel a, LocationModel b) =>
      a.address.trim().toLowerCase() == b.address.trim().toLowerCase() &&
          a.label.trim().toLowerCase() == b.label.trim().toLowerCase() &&
          _close(a.lat, b.lat) &&
          _close(a.lng, b.lng);

  LocationModel? _readLoc(String key) {
    final data = _storage.read(key);

    if (data is Map) {
      return LocationModel.fromJson(Map<String, dynamic>.from(data));
    }

    // Backward compatibility (older versions saved address only)
    if (data is String && data.trim().isNotEmpty) {
      return LocationModel(
        label: 'Home',
        address: data.trim(),
        lat: 0,
        lng: 0,
        isDefault: key == _kDefaultLoc,
      );
    }

    return null;
  }

  Future<void> _writeLoc(String key, LocationModel loc) async {
    await _storage.write(key, loc.toJson());
  }

  @override
  void onInit() {
    super.onInit();
    _loadDefault();
  }

  void _loadDefault() {
    final def = _readLoc(_kDefaultLoc);
    final l1 = _readLoc(_kLoc1);
    final l2 = _readLoc(_kLoc2);
    currentLocation.value = def ?? l1 ?? l2;
  }

  Future<void> setDefaultLocation(LocationModel loc) async {
    final def = loc.copyWith(isDefault: true);
    currentLocation.value = def;
    await _writeLoc(_kDefaultLoc, def);
  }

  Future<void> addLocation(LocationModel loc) async {
    final l1 = _readLoc(_kLoc1);
    final l2 = _readLoc(_kLoc2);

    // normalize non-default copy for slots
    final slotLoc = loc.copyWith(isDefault: false);

    if (l1 != null && _same(l1, slotLoc)) {
      await setDefaultLocation(l1);
      return;
    }
    if (l2 != null && _same(l2, slotLoc)) {
      await setDefaultLocation(l2);
      return;
    }

    if (l1 == null) {
      await _writeLoc(_kLoc1, slotLoc);
    } else if (l2 == null) {
      await _writeLoc(_kLoc2, slotLoc);
    } else {
      // policy: replace slot 2
      await _writeLoc(_kLoc2, slotLoc);
    }

    await setDefaultLocation(loc);
  }

  Future<void> clearAll() async {
    await _storage.remove(_kLoc1);
    await _storage.remove(_kLoc2);
    await _storage.remove(_kDefaultLoc);
    currentLocation.value = null;
  }

  Future<void> removeLocationSlot(int slot) async {
    if (slot == 1) await _storage.remove(_kLoc1);
    if (slot == 2) await _storage.remove(_kLoc2);
    _loadDefault();
  }

  void updateLocation(String address) {}


}