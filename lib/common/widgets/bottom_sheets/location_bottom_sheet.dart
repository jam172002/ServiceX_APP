import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

Future<String?> showLocationBottomSheet(BuildContext context) {
  // Track selected subtitle
  String selected = 'Model town B, Bahawalpur';

  return showModalBottomSheet<String>(
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

                  // Bahawalpur tile
                  _LocationTile(
                    title: "Bahawalpur",
                    subtitle: "Model town B, Bahawalpur",
                    isSelected: selected == "Model town B, Bahawalpur",
                    onTap: () =>
                        setState(() => selected = "Model town B, Bahawalpur"),
                  ),
                  const SizedBox(height: 8),

                  // Rajanpur tile
                  _LocationTile(
                    title: "Rajanpur",
                    subtitle: "Taga Colony, Rajanpur",
                    isSelected: selected == "Taga Colony, Rajanpur",
                    onTap: () =>
                        setState(() => selected = "Taga Colony, Rajanpur"),
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
                      onPressed: () => Get.back(result: selected),
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
