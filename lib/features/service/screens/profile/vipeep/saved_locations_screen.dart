import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:servicex_client_app/common/widgets/appbar/common_appbar.dart';
import 'package:servicex_client_app/features/authentication/controllers/location/vipeep_location_controller.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

class SavedLocationsScreen extends StatefulWidget {
  const SavedLocationsScreen({super.key});

  @override
  State<SavedLocationsScreen> createState() => _SavedLocationsScreenState();
}

class _SavedLocationsScreenState extends State<SavedLocationsScreen> {
  final LocationController locationController = Get.find<LocationController>();

  final RxList<Map<String, dynamic>> locations = <Map<String, dynamic>>[
    {"title": "Home", "address": "Model Town, Bahawalpur", "isDefault": true},
    {
      "title": "Office",
      "address": "Satellite Town, Bahawalpur",
      "isDefault": false,
    },
  ].obs;

  // ---------------- SET DEFAULT ----------------
  void setDefault(int index) {
    for (int i = 0; i < locations.length; i++) {
      locations[i]['isDefault'] = false;
    }
    locations[index]['isDefault'] = true;
    locationController.updateLocation(locations[index]['address']);
    locations.refresh();
  }

  // ---------------- DELETE CONFIRM ----------------
  void confirmDelete(int index) {
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
            onPressed: () {
              locations.removeAt(index);
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
    final titleController = TextEditingController(
      text: locations[index]['title'],
    );
    final addressController = TextEditingController(
      text: locations[index]['address'],
    );

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
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
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
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
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
            onPressed: () {
              final title = titleController.text.trim();
              final address = addressController.text.trim();
              if (title.isEmpty || address.isEmpty) return;

              locations[index]['title'] = title;
              locations[index]['address'] = address;

              if (locations[index]['isDefault'] == true) {
                locationController.updateLocation(address);
              }

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

  // ---------------- ADD (PLACEHOLDER) ----------------
  void addNewLocation() {}

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
                    title: item['title'],
                    address: item['address'],
                    isDefault: item['isDefault'],
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
