import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:servicex_client_app/domain/models/location_model.dart';
import 'package:servicex_client_app/domain/models/service_category.dart';
import 'package:servicex_client_app/presentation/screens/bookings/controller/create_booking_controller.dart';
import 'package:servicex_client_app/presentation/controllers/location_controller.dart';
import 'package:servicex_client_app/presentation/screens/service_provider_profile/service_provider_profile_screen.dart';
import 'package:servicex_client_app/presentation/widgets/common_appbar.dart';
import 'package:servicex_client_app/presentation/widgets/create_job_budget_section.dart';
import 'package:servicex_client_app/presentation/widgets/create_job_confirmation_dialog.dart';
import 'package:servicex_client_app/presentation/widgets/create_job_date_time_section.dart';
import 'package:servicex_client_app/presentation/widgets/create_job_details_section.dart';
import 'package:servicex_client_app/presentation/widgets/create_job_location_section.dart';
import 'package:servicex_client_app/presentation/widgets/create_job_payment_section.dart';
import 'package:servicex_client_app/presentation/widgets/location_bottom_sheet.dart';
import 'package:servicex_client_app/presentation/screens/location/location_selector_screen.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';
import 'package:servicex_client_app/utils/constants/images.dart';

/// Navigate here from a fixer profile or service-providers list:
///
/// ```dart
/// Get.to(() => CreateBookingScreen(
///   fixerId: fixer.uid,
///   fixerName: fixer.name,
///   fixerImageUrl: fixer.photoUrl,
///   fixerCategoryName: fixer.primaryCategory, // optional — auto-selects chip
/// ));
/// ```
class CreateBookingScreen extends StatefulWidget {
  final String fixerId;
  final String fixerName;
  final String? fixerImageUrl;

  /// If provided, the matching category chip is auto-selected on load.
  final String? fixerCategoryName;

  const CreateBookingScreen({
    super.key,
    required this.fixerId,
    required this.fixerName,
    this.fixerImageUrl,
    this.fixerCategoryName,
  });

  @override
  State<CreateBookingScreen> createState() => _CreateBookingScreenState();
}

class _CreateBookingScreenState extends State<CreateBookingScreen> {
  late final CreateBookingController _c;

  @override
  void initState() {
    super.initState();
    _c = Get.put(CreateBookingController());

    // Wire fixer data into the controller
    _c.fixerId = widget.fixerId;
    _c.fixerName = widget.fixerName;
    _c.fixerImageUrl = widget.fixerImageUrl;
    _c.preselectedCategoryName = widget.fixerCategoryName;
  }

  @override
  void dispose() {
    Get.delete<CreateBookingController>();
    super.dispose();
  }

  // ── Location ──────────────────────────────────────────────────
  Future<void> _editLocation() async {
    final result = await showLocationBottomSheet(context);
    if (result == null) return;

    final locationController = Get.find<LocationController>();

    if (result is String && result == 'pick_on_map') {
      final picked =
      await Get.to<LocationModel>(() => const LocationSelectorScreen());
      if (picked != null && picked.address.trim().isNotEmpty) {
        await locationController.addLocation(picked);
      }
      return;
    }

    if (result is LocationModel) {
      await locationController.setDefaultLocation(result);
      return;
    }

    if (result is String && result.trim().isNotEmpty) {
      final loc = LocationModel(
        label: 'Home',
        address: result.trim(),
        lat: 0,
        lng: 0,
        isDefault: true,
      );
      await locationController.setDefaultLocation(loc);
      return;
    }

    Get.snackbar('Location', 'Invalid selection');
  }

  // ── Date / Time ───────────────────────────────────────────────
  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _c.selectedDate.value ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(
            primary: XColors.primary,
            onPrimary: Colors.white,
            onSurface: XColors.black,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) _c.selectedDate.value = picked;
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _c.selectedTime.value ?? TimeOfDay.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(
            primary: XColors.primary,
            onPrimary: Colors.white,
            onSurface: XColors.black,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) _c.selectedTime.value = picked;
  }

  // ── Submit ────────────────────────────────────────────────────
  void _submit() {
    final error = _c.validate();
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    // Bookings are always direct (forAll = false) — skip the choice dialog
    _showConfirmationDialog();
  }

  void _showConfirmationDialog() {
    final payload = _c.buildDisplayPayload(context);

    showDialog(
      context: context,
      builder: (ctx) => ConfirmationDialog(
        service: payload['categoryName'] as String,
        subType: payload['subcategoryName'] as String?,
        details: payload['details'] as String,
        location: payload['location'] as String,
        date: payload['date'] as String,
        time: payload['time'] as String,
        budgetMin: payload['budgetMin'] as int,
        budgetMax: payload['budgetMax'] as int,
        payment: payload['payment'] as String,
        images: payload['images'] as List<File>,
        forAll: false, // always direct booking
        onConfirm: () {
          _c.createBooking(
            onSuccess: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Booking sent to ${widget.fixerName}!',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const XAppBar(title: 'Book a Fixer'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Fixer card (always shown) ─────────────────────
            _buildFixerCard(),

            // ── Service Type chips ────────────────────────────
            _buildCategoryRow(),

            const SizedBox(height: 12),

            // ── Sub-Type dropdown ─────────────────────────────
            const Text(
              'Sub-Type',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            _buildSubcategoryDropdown(),

            const SizedBox(height: 12),

            // ── Details + images ──────────────────────────────
            Obx(() {
              final images = _c.pickedImages.toList();
              return DetailsSection(
                detailsController: _c.detailsController,
                pickedImages: images,
                onPickImages: _c.pickImages,
                onPickCameraImage: _c.pickImageFromCamera,
                onRemoveImage: _c.removeImage,
              );
            }),

            const SizedBox(height: 20),

            // ── Location ──────────────────────────────────────
            Obx(() {
              final address =
                  _c.locationController.currentLocation.value?.address ??
                      'Select location';
              return LocationSection(
                location: address,
                onEdit: _editLocation,
              );
            }),

            const SizedBox(height: 20),

            // ── Date & Time ───────────────────────────────────
            Obx(() => DateTimeSection(
              selectedDate: _c.selectedDate.value,
              selectedTime: _c.selectedTime.value,
              onSelectDate: _selectDate,
              onSelectTime: _selectTime,
            )),

            const SizedBox(height: 20),

            // ── Budget ────────────────────────────────────────
            Obx(() => BudgetSection(
              minController: _c.minController,
              maxController: _c.maxController,
              budgetRange: _c.budgetRange.value,
              onChanged: _c.updateBudgetRange,
            )),

            const SizedBox(height: 20),

            // ── Payment ───────────────────────────────────────
            Obx(() => PaymentSection(
              selectedPayment: _c.selectedPayment.value,
              onSelect: (val) => _c.selectedPayment.value = val,
            )),

            const SizedBox(height: 25),

            // ── Confirm Booking button ────────────────────────
            Obx(() {
              final submitting = _c.isSubmitting.value;
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: submitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: XColors.primary,
                    disabledBackgroundColor:
                    XColors.primary.withValues(alpha: 0.5),
                  ),
                  child: submitting
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text(
                    'Confirm Booking',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              );
            }),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ── Fixer card ────────────────────────────────────────────────
  Widget _buildFixerCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fixer',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 28,
              backgroundImage: widget.fixerImageUrl != null &&
                  widget.fixerImageUrl!.isNotEmpty
                  ? NetworkImage(widget.fixerImageUrl!) as ImageProvider
                  : AssetImage(XImages.serviceProvider),
            ),
            const SizedBox(width: 12),
            // Name + category
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.fixerName,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  if (widget.fixerCategoryName != null)
                    Text(
                      widget.fixerCategoryName!,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                ],
              ),
            ),
            // View profile
            IconButton.filled(
              onPressed: () => Get.to(() => ServiceProviderProfileScreen()),
              icon: const Icon(Iconsax.user, size: 18),
              style: IconButton.styleFrom(
                backgroundColor: XColors.primary.withValues(alpha: 0.2),
                foregroundColor: XColors.primary,
              ),
            ),
            // Message
            IconButton.filled(
              onPressed: () {
                // TODO: navigate to chat screen with fixerId
              },
              icon: const Icon(Iconsax.sms, size: 18),
              style: IconButton.styleFrom(
                backgroundColor: XColors.primary.withValues(alpha: 0.2),
                foregroundColor: XColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // ── Category chips ────────────────────────────────────────────
  Widget _buildCategoryRow() {
    return Obx(() {
      final isLoading = _c.categoriesLoading.value;
      final hasError = _c.categoriesError.value.isNotEmpty;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Service Type',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 90,
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : hasError
                ? Center(
              child: Text(
                'Could not load categories',
                style: TextStyle(
                    color: Colors.red.shade400, fontSize: 12),
              ),
            )
                : ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _c.categories.length,
              separatorBuilder: (_, __) =>
              const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final cat = _c.categories[i];
                return Obx(() => _CategoryChip(
                  category: cat,
                  isSelected:
                  _c.selectedCategory.value?.id == cat.id,
                  onTap: () => _c.selectCategory(cat),
                ));
              },
            ),
          ),
        ],
      );
    });
  }

  // ── Subcategory dropdown ──────────────────────────────────────
  Widget _buildSubcategoryDropdown() {
    return Obx(() {
      final isLoading = _c.subcategoriesLoading.value;
      final subs = _c.subcategories;
      final noCat = _c.selectedCategory.value == null;

      return DropdownButtonFormField<String>(
        initialValue: _c.selectedSubcategory.value?.id,
        hint: Text(
          isLoading
              ? 'Loading…'
              : noCat
              ? 'Select category first'
              : subs.isEmpty
              ? 'No sub-types available'
              : 'Select sub-type',
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        dropdownColor: XColors.secondaryBG,
        decoration: InputDecoration(
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: XColors.borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: XColors.borderColor),
          ),
          filled: true,
          fillColor: XColors.secondaryBG,
        ),
        items: (isLoading || subs.isEmpty)
            ? null
            : subs
            .map((sub) => DropdownMenuItem<String>(
          value: sub.id,
          child: Text(sub.name,
              style: const TextStyle(fontSize: 13)),
        ))
            .toList(),
        onChanged: (!noCat && !isLoading && subs.isNotEmpty)
            ? (val) {
          final sub = subs.firstWhereOrNull((s) => s.id == val);
          if (sub != null) _c.selectSubcategory(sub);
        }
            : null,
      );
    });
  }
}

// ── Category chip (local — identical to CreateServiceJobScreen's) ─────────────
class _CategoryChip extends StatelessWidget {
  final ServiceCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 72,
        decoration: BoxDecoration(
          color: isSelected
              ? XColors.primary.withValues(alpha: 0.12)
              : XColors.secondaryBG,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? XColors.primary : XColors.borderColor,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: category.iconUrl.isNotEmpty
                  ? Image.network(
                category.iconUrl,
                fit: BoxFit.contain,
                loadingBuilder: (_, child, progress) =>
                progress == null
                    ? child
                    : const Padding(
                  padding: EdgeInsets.all(6),
                  child: CircularProgressIndicator(
                      strokeWidth: 1.5),
                ),
                errorBuilder: (_, __, ___) => Icon(
                  Icons.build_outlined,
                  size: 26,
                  color: isSelected ? XColors.primary : XColors.grey,
                ),
              )
                  : Icon(
                Icons.build_outlined,
                size: 26,
                color: isSelected ? XColors.primary : XColors.grey,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              category.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight:
                isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? XColors.primary : XColors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}