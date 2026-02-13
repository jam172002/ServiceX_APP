import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get_storage/get_storage.dart';

import 'package:servicex_client_app/presentation/widgets/common_appbar.dart';
import 'package:servicex_client_app/presentation/controllers/location_controller.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

import '../../../domain/models/location_model.dart';
import '../location/location_selector_screen.dart';

class SavedLocationsScreen extends StatefulWidget {
  const SavedLocationsScreen({super.key});

  @override
  State<SavedLocationsScreen> createState() => _SavedLocationsScreenState();
}

class _SavedLocationsScreenState extends State<SavedLocationsScreen> {
  final LocationController locationController = Get.find<LocationController>();
  final GetStorage _box = GetStorage();

  // Must match controller keys
  static const String _kLoc1 = 'saved_location_1';
  static const String _kLoc2 = 'saved_location_2';
  static const String _kDefaultLoc = 'default_location';

  // Local reactive list for UI (keeps your UI unchanged)
  final RxList<Map<String, dynamic>> locations = <Map<String, dynamic>>[].obs;

  @override
  void initState() {
    super.initState();
    _loadFromStorage();
  }

  // ---------------- STORAGE HELPERS ----------------
  LocationModel? _readLoc(String key) {
    final data = _box.read(key);
    if (data is Map) {
      return LocationModel.fromJson(Map<String, dynamic>.from(data));
    }
    // Backward compatibility (old String-only storage)
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
    await _box.write(key, loc.toJson());
  }

  bool _same(LocationModel a, LocationModel b) {
    bool close(double x, double y, [double eps = 0.00001]) => (x - y).abs() < eps;

    return a.address.trim().toLowerCase() == b.address.trim().toLowerCase() &&
        a.label.trim().toLowerCase() == b.label.trim().toLowerCase() &&
        close(a.lat, b.lat) &&
        close(a.lng, b.lng);
  }

  void _loadFromStorage() {
    final l1 = _readLoc(_kLoc1);
    final l2 = _readLoc(_kLoc2);
    final def = _readLoc(_kDefaultLoc);

    final saved = <LocationModel>[
      if (l1 != null && l1.address.trim().isNotEmpty) l1,
      if (l2 != null && l2.address.trim().isNotEmpty) l2,
    ];

    // Determine default by comparing with stored default (if present)
    int defaultIndex = -1;
    if (def != null) {
      defaultIndex = saved.indexWhere((x) => _same(x, def));
    }
    if (defaultIndex < 0 && saved.isNotEmpty) defaultIndex = 0;

    final uiList = <Map<String, dynamic>>[];
    for (int i = 0; i < saved.length; i++) {
      uiList.add({
        "title": saved[i].label.isEmpty ? (i == 0 ? "Home" : "Office") : saved[i].label,
        "address": saved[i].address,
        "isDefault": i == defaultIndex,
        "_model": saved[i], // keep full model for edit/delete/set default
      });
    }

    locations.assignAll(uiList);

    // Keep controller in sync (important if this screen is first opened)
    if (defaultIndex >= 0 && defaultIndex < saved.length) {
      locationController.setDefaultLocation(saved[defaultIndex]);
    }
  }

  Future<void> _syncBackToStorage() async {
    // Expect at most 2
    if (locations.isEmpty) {
      await _box.remove(_kLoc1);
      await _box.remove(_kLoc2);
      await _box.remove(_kDefaultLoc);
      locationController.currentLocation.value = null;
      return;
    }

    LocationModel? m0 = locations.length > 0 ? (locations[0]["_model"] as LocationModel?) : null;
    LocationModel? m1 = locations.length > 1 ? (locations[1]["_model"] as LocationModel?) : null;

    if (m0 != null) await _writeLoc(_kLoc1, m0.copyWith(isDefault: false));
    if (m1 != null) await _writeLoc(_kLoc2, m1.copyWith(isDefault: false));
    if (m0 == null) await _box.remove(_kLoc1);
    if (m1 == null) await _box.remove(_kLoc2);

    final defIdx = locations.indexWhere((e) => e["isDefault"] == true);
    if (defIdx >= 0) {
      final defModel = locations[defIdx]["_model"] as LocationModel;
      await _writeLoc(_kDefaultLoc, defModel.copyWith(isDefault: true));
      await locationController.setDefaultLocation(defModel.copyWith(isDefault: true));
    } else {
      // if none marked default, default to first
      final defModel = locations.first["_model"] as LocationModel;
      locations.first["isDefault"] = true;
      locations.refresh();
      await _writeLoc(_kDefaultLoc, defModel.copyWith(isDefault: true));
      await locationController.setDefaultLocation(defModel.copyWith(isDefault: true));
    }
  }

  // ---------------- SET DEFAULT ----------------
  Future<void> setDefault(int index) async {
    if (index < 0 || index >= locations.length) return;

    for (int i = 0; i < locations.length; i++) {
      locations[i]['isDefault'] = false;
    }
    locations[index]['isDefault'] = true;
    locations.refresh();

    await _syncBackToStorage();
  }

  // ---------------- DELETE CONFIRM ----------------
  void confirmDelete(int index) {
    if (index < 0 || index >= locations.length) return;

    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
        title: const Text(
          'Delete Location',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        content: const Text(
          'Are you sure you want to delete this location?',
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
        actions: [
          TextButton(
            onPressed: Get.back,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              foregroundColor: Colors.grey.shade700,
            ),
            child: const Text('Cancel', style: TextStyle(fontSize: 13)),
          ),
          ElevatedButton(
            onPressed: () async {
              final wasDefault = locations[index]["isDefault"] == true;
              locations.removeAt(index);

              // If deleted default, set first as default (if exists)
              if (wasDefault && locations.isNotEmpty) {
                for (final e in locations) {
                  e["isDefault"] = false;
                }
                locations.first["isDefault"] = true;
                locations.refresh();
              }

              await _syncBackToStorage();
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: XColors.danger,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              side: BorderSide(color: XColors.danger, width: 0),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Delete',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- EDIT (TITLE + LOCATION) ----------------
  void editLocation(int index) {
    if (index < 0 || index >= locations.length) return;

    final currentModel = locations[index]["_model"] as LocationModel;

    final titleController = TextEditingController(text: locations[index]['title']?.toString() ?? "");
    final addressController = TextEditingController(text: locations[index]['address']?.toString() ?? "");

    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
        title: const Text(
          'Edit Location',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Title',
                isDense: true,
                filled: true,
                fillColor: XColors.secondaryBG,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: addressController,
              maxLines: 2,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Location',
                isDense: true,
                filled: true,
                fillColor: XColors.secondaryBG,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
        actions: [
          TextButton(
            onPressed: Get.back,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              foregroundColor: Colors.grey.shade700,
            ),
            child: const Text('Cancel', style: TextStyle(fontSize: 13)),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = titleController.text.trim();
              final address = addressController.text.trim();
              if (title.isEmpty || address.isEmpty) return;

              // Keep lat/lng as-is (since UI is not map-based here)
              final updatedModel = currentModel.copyWith(
                label: title,
                address: address,
              );

              locations[index]['title'] = title;
              locations[index]['address'] = address;
              locations[index]['_model'] = updatedModel;

              // If default edited, sync controller & storage
              await _syncBackToStorage();

              locations.refresh();
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: XColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Save',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- ADD NEW (PICK ON MAP, NO UI CHANGE) ----------------
  Future<void> addNewLocation() async {
    // keep behaviour professional:
    // - allow max 2 saved locations (matches your controller design)
    if (locations.length >= 2) {
      Get.snackbar("Limit reached", "You can save only 2 locations.");
      return;
    }

    final picked = await Get.to<LocationModel>(() => const LocationSelectorScreen());
    if (picked == null || picked.address.trim().isEmpty) return;

    // If first location -> label Home, second -> Office (keeps your UI titles)
    final suggestedLabel = locations.isEmpty ? "Home" : "Office";
    final toSave = picked.copyWith(label: suggestedLabel, isDefault: false);

    locations.add({
      "title": toSave.label,
      "address": toSave.address,
      "isDefault": locations.isEmpty, // first becomes default
      "_model": toSave,
    });

    // If it's first, make it default in controller too
    await _syncBackToStorage();
    locations.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: XAppBar(title: 'Saved Locations'),
      body: Obx(
            () => locations.isEmpty
            ? const _EmptyState()
            : ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          itemCount: locations.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final item = locations[index];
            return _LocationTile(
              title: item['title'] as String,
              address: item['address'] as String,
              isDefault: item['isDefault'] as bool,
              onTap: () => setDefault(index),
              onEdit: () => editLocation(index),
              onDelete: () => confirmDelete(index),
            );
          },
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        child: ElevatedButton(
          onPressed: addNewLocation,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Text(
            'Add New Location',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

// ---------------- LOCATION TILE ----------------
class _LocationTile extends StatelessWidget {
  final String title;
  final String address;
  final bool isDefault;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _LocationTile({
    required this.title,
    required this.address,
    required this.isDefault,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(
              Iconsax.location,
              size: 18,
              color: isDefault ? Colors.green : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (isDefault) ...[
                        const SizedBox(width: 6),
                        const Text(
                          '• Default',
                          style: TextStyle(fontSize: 11, color: Colors.green),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(Iconsax.edit, color: XColors.primary, size: 18),
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: const Icon(Iconsax.trash, size: 18, color: Colors.red),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- EMPTY STATE ----------------
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'No saved locations',
        style: TextStyle(fontSize: 13, color: Colors.grey),
      ),
    );
  }
}