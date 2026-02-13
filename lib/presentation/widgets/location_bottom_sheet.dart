import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

import '../../domain/models/location_model.dart';

Future<dynamic> showLocationBottomSheet(BuildContext context) {
  final box = GetStorage();

  const kLoc1 = 'saved_location_1';
  const kLoc2 = 'saved_location_2';
  const kDefaultLoc = 'default_location';

  LocationModel? selected;

  LocationModel? _readLoc(String key) {
    final data = box.read(key);

    // New storage format: Map JSON
    if (data is Map) {
      return LocationModel.fromJson(Map<String, dynamic>.from(data));
    }

    // Backward compatibility: old format was just address string
    if (data is String && data.trim().isNotEmpty) {
      return LocationModel(
        label: 'Home',
        address: data.trim(),
        lat: 0,
        lng: 0,
        isDefault: key == kDefaultLoc,
      );
    }

    return null;
  }

  Future<void> _writeLoc(String key, LocationModel loc) async {
    await box.write(key, loc.toJson());
  }

  bool _same(LocationModel a, LocationModel b) {
    bool close(double x, double y, [double eps = 0.00001]) => (x - y).abs() < eps;

    return a.address.trim().toLowerCase() == b.address.trim().toLowerCase() &&
        a.label.trim().toLowerCase() == b.label.trim().toLowerCase() &&
        close(a.lat, b.lat) &&
        close(a.lng, b.lng);
  }

  return showModalBottomSheet<dynamic>(
    context: context,
    isScrollControlled: true,
    backgroundColor: XColors.secondaryBG,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (context) {
      return SafeArea(
        child: StatefulBuilder(
          builder: (context, setState) {
            // ✅ Read latest values each rebuild
            final loc1 = _readLoc(kLoc1);
            final loc2 = _readLoc(kLoc2);
            final def = _readLoc(kDefaultLoc);

            final saved = <LocationModel>[
              if (loc1 != null && loc1.address.trim().isNotEmpty) loc1,
              if (loc2 != null && loc2.address.trim().isNotEmpty) loc2,
            ];

            // ✅ Initialize selection safely
            if (selected == null) {
              if (def != null && saved.any((x) => _same(x, def))) {
                selected = saved.firstWhere((x) => _same(x, def));
              } else if (saved.isNotEmpty) {
                selected = saved.first;
              }
            } else if (saved.isNotEmpty && !saved.any((x) => _same(x, selected!))) {
              selected = saved.first;
            }

            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  const Text(
                    "Choose Your Location",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: XColors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Saved address",
                    style: TextStyle(fontSize: 13, color: XColors.grey),
                  ),
                  const SizedBox(height: 12),

                  // ---- TILE 1 ----
                  if (saved.isNotEmpty)
                    _LocationTile(
                      title: "Location 1",
                      subtitle: saved[0].address,
                      isSelected: selected != null && _same(selected!, saved[0]),
                      onTap: () => setState(() => selected = saved[0]),
                    ),

                  if (saved.isNotEmpty) const SizedBox(height: 8),

                  // ---- TILE 2 ----
                  if (saved.length > 1)
                    _LocationTile(
                      title: "Location 2",
                      subtitle: saved[1].address,
                      isSelected: selected != null && _same(selected!, saved[1]),
                      onTap: () => setState(() => selected = saved[1]),
                    ),

                  const SizedBox(height: 20),
                  const Divider(height: 1, color: XColors.borderColor),
                  const SizedBox(height: 20),

                  _BottomButton(
                    icon: Iconsax.location_add,
                    title: "Set to a different location",
                    subtitle: "Choose location on map",
                    onTap: () => Get.back(result: "pick_on_map"),
                  ),
                  const SizedBox(height: 20),

                  // Confirm button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: selected == null
                          ? null
                          : () async {
                        final defLoc = selected!.copyWith(isDefault: true);
                        await _writeLoc(kDefaultLoc, defLoc);
                        Get.back(result: defLoc); // ✅ return LocationModel
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: XColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Confirm Selection",
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}

class _LocationTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _LocationTile({
    required this.title,
    required this.subtitle,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? XColors.secondaryBG : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Iconsax.location5, size: 22, color: XColors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 13, color: XColors.grey),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: XColors.primary, size: 22),
          ],
        ),
      ),
    );
  }
}

class _BottomButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _BottomButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: XColors.borderColor),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: XColors.success),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            ),
            const Icon(Icons.keyboard_arrow_right),
          ],
        ),
      ),
    );
  }
}