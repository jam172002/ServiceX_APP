import 'dart:io';

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

class FixxerEditProfileScreen extends StatefulWidget {
  const FixxerEditProfileScreen({super.key});

  @override
  State<FixxerEditProfileScreen> createState() =>
      _FixxerEditProfileScreenState();
}

class _FixxerEditProfileScreenState extends State<FixxerEditProfileScreen> {
  // ================= DATA =================

  String name = 'Muhammad Sufyan';
  String email = 'example@email.com';
  String phone = '+92 300 0000000';
  String hourlyRate = '1500';
  String experience = '5';
  String maxBookings = '5';

  String gender = 'Male';
  String bookingType = 'Instant';
  String category = 'Plumber';

  final List<String> genders = ['Male', 'Female', 'Other'];
  final List<String> bookingTypes = ['Instant', 'Manual'];

  List<String> languages = ['English', 'Urdu'];
  List<String> subCategories = ['Pipe Fitting'];
  List<String> serviceAreas = ['Bahawalpur'];

  final Map<String, bool> weeklyAvailability = {
    'Mon': true,
    'Tue': true,
    'Wed': true,
    'Thu': true,
    'Fri': true,
    'Sat': false,
    'Sun': false,
  };

  // ======== IMAGE HANDLING ========
  File? profileImage;
  File? bannerImage;
  List<File> serviceImages = [];

  final ImagePicker _picker = ImagePicker();

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _profileHeader(colors),
                const SizedBox(height: 90),

                _sectionTitle('Basic Details'),
                _editTile(
                  Iconsax.user,
                  'Name',
                  name,
                  () => _editText('Name', name, (v) => name = v),
                ),
                _editTile(
                  Iconsax.sms,
                  'Email',
                  email,
                  () => _editText('Email', email, (v) => email = v),
                ),
                _editTile(
                  Iconsax.call,
                  'Phone',
                  phone,
                  () => _editText('Phone', phone, (v) => phone = v),
                ),

                _chipSelector(
                  'Gender',
                  genders,
                  gender,
                  (val) => setState(() => gender = val),
                ),

                _editTile(
                  Iconsax.money,
                  'Hourly Rate',
                  hourlyRate,
                  () => _editText(
                    'Hourly Rate',
                    hourlyRate,
                    (v) => hourlyRate = v,
                  ),
                ),
                _editTile(
                  Iconsax.briefcase,
                  'Experience (Years)',
                  experience,
                  () => _editText(
                    'Experience',
                    experience,
                    (v) => experience = v,
                  ),
                ),

                _chipEditableSection('Languages Spoken', languages),
                _weeklySchedule(colors),

                _sectionTitle('Service Details'),
                _categoryDropdown(),
                _chipEditableSection('Sub Categories', subCategories),
                _chipEditableSection('Service Areas', serviceAreas),
                _photoAddSection(colors),

                _sectionTitle('Business Settings'),

                _chipSelector(
                  'Booking Type',
                  bookingTypes,
                  bookingType,
                  (val) => setState(() => bookingType = val),
                ),
                _editTile(
                  Iconsax.calendar,
                  'Max Bookings / Day',
                  maxBookings,
                  () => _editText(
                    'Max Bookings',
                    maxBookings,
                    (v) => maxBookings = v,
                  ),
                ),
              ],
            ),
          ),

          // ================= SAVE BUTTON =================
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Save Changes',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= HEADER =================

  Widget _profileHeader(ColorScheme colors) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Banner Image
        Container(
          height: 200,
          width: double.infinity,
          color: Colors.grey[300],
          child: bannerImage == null
              ? const Icon(Icons.image, size: 60)
              : Image.file(bannerImage!, fit: BoxFit.cover),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: _iconCircle(Iconsax.camera, onTap: _pickBannerImage),
        ),

        // Profile Avatar
        Positioned(
          bottom: -55,
          left: 16,
          child: Stack(
            children: [
              GestureDetector(
                onTap: _pickProfileImage,
                child: CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.grey[500],
                  foregroundImage: profileImage != null
                      ? FileImage(profileImage!)
                      : null,
                  child: profileImage == null
                      ? const Icon(Iconsax.user, size: 40)
                      : null,
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => setState(() => profileImage = null),
                  child: _iconCircle(Iconsax.close_circle),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _iconCircle(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: XColors.black.withValues(alpha: 0.4),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: Colors.white),
      ),
    );
  }

  // ================= EDIT TEXT =================

  void _editText(String title, String value, Function(String) onSave) {
    final controller = TextEditingController(text: value);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: XColors.primaryBG,
        title: Text('Edit $title', style: TextStyle(color: XColors.black)),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => onSave(controller.text));
              Navigator.pop(context);
            },
            style: ButtonStyle(
              padding: const WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              ),
            ),
            child: const Text('Save', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  // ================= CHIPS =================

  Widget _chipSelector(
    String title,
    List<String> items,
    String selected,
    Function(String) onSelect,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Wrap(
            spacing: 8,
            children: items
                .map(
                  (e) => ChoiceChip(
                    selected: selected == e,
                    backgroundColor: XColors.secondaryBG,
                    selectedColor: XColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    label: Text(
                      e,
                      style: TextStyle(
                        fontSize: 14,
                        color: selected == e ? Colors.white : Colors.black,
                      ),
                    ),
                    onSelected: (_) => onSelect(e),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _chipEditableSection(String title, List<String> list) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 11)),
          Wrap(
            spacing: 8,
            children: [
              ...list.map(
                (e) => Chip(
                  label: Text(
                    e,
                    style: TextStyle(color: XColors.grey, fontSize: 13),
                  ),
                  backgroundColor: Colors.grey[300],
                  deleteIconColor: Colors.black54,
                  side: const BorderSide(color: Colors.transparent),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  onDeleted: () => setState(() => list.remove(e)),
                ),
              ),
              ActionChip(
                backgroundColor: XColors.primary,
                avatar: const Icon(Iconsax.add, color: Colors.white, size: 16),
                label: const Text('Add', style: TextStyle(fontSize: 13)),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: Colors.transparent),
                ),
                onPressed: () =>
                    _editText(title, '', (v) => setState(() => list.add(v))),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= WEEKLY =================

  Widget _weeklySchedule(ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: weeklyAvailability.keys.map((day) {
          final active = weeklyAvailability[day]!;
          return GestureDetector(
            onTap: () => setState(() => weeklyAvailability[day] = !active),
            child: Container(
              padding: const EdgeInsets.all(12),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: active ? Colors.green : Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                day,
                style: TextStyle(
                  fontSize: 11,
                  color: active ? Colors.white : Colors.grey,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ================= CATEGORY =================

  Widget _categoryDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: DropdownButtonFormField<String>(
        dropdownColor: XColors.secondaryBG,
        initialValue: category,
        decoration: const InputDecoration(labelText: 'Main Category'),
        style: TextStyle(fontSize: 12, color: XColors.black),
        items: [
          'Plumber',
          'Electrician',
          'Painter',
        ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: (v) => setState(() => category = v!),
      ),
    );
  }

  // ================= PHOTOS =================

  Widget _photoAddSection(ColorScheme colors) {
    return SizedBox(
      height: 80,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        children: [
          ...serviceImages.map((img) => _photoTileFromFile(img)),
          _photoTile(colors, Iconsax.add, onTap: _pickServiceImage),
        ],
      ),
    );
  }

  Widget _photoTile(ColorScheme colors, IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: XColors.black),
      ),
    );
  }

  Widget _photoTileFromFile(File file) {
    return Stack(
      children: [
        Container(
          width: 80,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(image: FileImage(file), fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: GestureDetector(
            onTap: () => setState(() => serviceImages.remove(file)),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  // ================= IMAGE PICKERS =================

  Future<void> _pickBannerImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => bannerImage = File(picked.path));
  }

  Future<void> _pickProfileImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => profileImage = File(picked.path));
  }

  Future<void> _pickServiceImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => serviceImages.add(File(picked.path)));
  }

  // ================= SAVE =================

  void _saveProfile() {
    debugPrint('Profile Saved');
    debugPrint('Name: $name, Email: $email, Phone: $phone');
    debugPrint('Profile Image: ${profileImage?.path}');
    debugPrint('Banner Image: ${bannerImage?.path}');
    debugPrint('Service Images: ${serviceImages.map((e) => e.path).toList()}');
  }

  // ================= SECTION & TILE =================

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _editTile(
    IconData icon,
    String title,
    String value,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: XColors.primary, size: 20),
      title: Text(title, style: TextStyle(fontSize: 13, color: XColors.black)),
      subtitle: Text(value, style: TextStyle(color: XColors.grey)),
      trailing: const Icon(Iconsax.edit, color: XColors.success, size: 18),
      dense: true,
      onTap: onTap,
    );
  }
}
