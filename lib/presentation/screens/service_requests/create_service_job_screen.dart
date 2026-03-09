import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:servicex_client_app/domain/models/location_model.dart';
import 'package:servicex_client_app/domain/models/service_category.dart';
import 'package:servicex_client_app/presentation/screens/service_requests/controller/job_controller.dart';
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

class CreateServiceJobScreen extends StatefulWidget {
  final bool showServiceProviderCard;
  final String? spName;
  final String? spType;        // category name to pre-select when coming from SP profile
  final String? spImage;
  final String? spProviderId;  // SP uid for personal requests

  const CreateServiceJobScreen({
    super.key,
    required this.showServiceProviderCard,
    this.spName,
    this.spType,
    this.spImage,
    this.spProviderId,
  });

  @override
  State<CreateServiceJobScreen> createState() => _CreateServiceJobScreenState();
}

class _CreateServiceJobScreenState extends State<CreateServiceJobScreen> {
  late final CreateJobController _c;

  @override
  void initState() {
    super.initState();
    _c = Get.put(CreateJobController());

    if (widget.showServiceProviderCard) {
      _c.preselectedSpType = widget.spType;
      _c.preselectedProviderId = widget.spProviderId;
    }
  }

  @override
  void dispose() {
    Get.delete<CreateJobController>();
    super.dispose();
  }

  // ── Location ─────────────────────────────────────────────────
  Future<void> _editLocation() async {
    final result = await showLocationBottomSheet(context);
    if (result == null) return;

    final locationController = Get.find<LocationController>();

    if (result is String && result == 'pick_on_map') {
      final picked = await Get.to<LocationModel>(() => const LocationSelectorScreen());
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

  // ── Date / Time ──────────────────────────────────────────────
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

  // ── Submit flow ──────────────────────────────────────────────
  void _submit() {
    final error = _c.validate();
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create Job'),
        content: const Text('How do you want to create this job?'),
        backgroundColor: XColors.secondaryBG,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showConfirmationDialog(forAll: true);
            },
            child: const Text('Open for All', style: TextStyle(color: XColors.primary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showConfirmationDialog(forAll: false);
            },
            child: const Text('Send to Personal', style: TextStyle(color: XColors.primary)),
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialog({required bool forAll}) {
    // buildDisplayPayload gives us properly typed values for the dialog
    final payload = _c.buildDisplayPayload(context, forAll: forAll);

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
        images: payload['images'] as List<File>, // ✅ typed — no cast error
        forAll: payload['forAll'] as bool,
        onConfirm: () {
          // ✅ Real Firestore creation via JobRepository
          _c.createJob(
            forAll: forAll,
            onSuccess: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    forAll
                        ? 'Job created and opened for all providers!'
                        : 'Job request sent to your selected provider!',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const XAppBar(title: 'Create Job'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //? Service Provider Card
            if (widget.showServiceProviderCard) _buildSpCard(),

            //? Service Type — horizontal chips (Firebase categories)
            _buildCategoryRow(),

            const SizedBox(height: 12),

            //? Sub-Type
            Text(
              "Sub-Type",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            _buildSubcategoryDropdown(),

            const SizedBox(height: 12),

            //? Details + images
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

            //? Location
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

            //? Date & Time
            Obx(() => DateTimeSection(
              selectedDate: _c.selectedDate.value,
              selectedTime: _c.selectedTime.value,
              onSelectDate: _selectDate,
              onSelectTime: _selectTime,
            )),

            const SizedBox(height: 20),

            //? Budget
            Obx(() => BudgetSection(
              minController: _c.minController,
              maxController: _c.maxController,
              budgetRange: _c.budgetRange.value,
              onChanged: _c.updateBudgetRange,
            )),

            const SizedBox(height: 20),

            //? Payment
            Obx(() => PaymentSection(
              selectedPayment: _c.selectedPayment.value,
              onSelect: (val) => _c.selectedPayment.value = val,
            )),

            const SizedBox(height: 25),

            //? Submit
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
                    'Create Job',
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

  // ── Section helpers ──────────────────────────────────────────

  Widget _buildCategoryRow() {
    return Obx(() {
      final isLoading = _c.categoriesLoading.value;
      final hasError = _c.categoriesError.value.isNotEmpty;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Label — same as ServiceTypeSection renders it internally ──
          const Text(
            'Service Type',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const SizedBox(height: 12),

          // ── Chips row ─────────────────────────────────────────────
          SizedBox(
            height: 90,
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : hasError
                ? Center(
              child: Text(
                'Could not load categories',
                style: TextStyle(color: Colors.red.shade400, fontSize: 12),
              ),
            )
                : ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _c.categories.length + 1, // +1 for "Other"
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                // Last item → "Other" tile
                if (i == _c.categories.length) {
                  return _OtherChip(
                    onTap: () {
                      // No AllServicesDialog with Firebase — just a no-op
                      // or you can show a search bottom sheet later
                    },
                  );
                }
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
          child: Text(sub.name, style: const TextStyle(fontSize: 13)),
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

  Widget _buildSpCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Service Provider',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            CircleAvatar(
              radius: 35,
              backgroundImage: AssetImage(widget.spImage ?? XImages.serviceProvider),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.spName ?? 'Unknown',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    widget.spType ?? 'Unknown',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
            IconButton.filled(
              onPressed: () => Get.to(() => ServiceProviderProfileScreen()),
              icon: const Icon(Iconsax.user, size: 18),
              style: IconButton.styleFrom(
                backgroundColor: XColors.primary.withValues(alpha: 0.2),
                foregroundColor: XColors.primary,
              ),
            ),
            IconButton.filled(
              onPressed: () {},
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
}

// ── Other Chip (matches original AllServices tile) ───────────────────────────
class _OtherChip extends StatelessWidget {
  final VoidCallback onTap;
  const _OtherChip({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        decoration: BoxDecoration(
          color: XColors.secondaryBG,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: XColors.borderColor, width: 1),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.grid_view_rounded, size: 26, color: XColors.grey),
            const SizedBox(height: 5),
            const Text(
              'Other',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: XColors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


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
            // ── Icon from Firebase Storage URL ──────────────────
            // Uses Image.network (built-in) — no extra package needed.
            // Falls back to a material icon on error or empty URL.
            SizedBox(
              width: 32,
              height: 32,
              child: category.iconUrl.isNotEmpty
                  ? Image.network(
                category.iconUrl,
                fit: BoxFit.contain,
                loadingBuilder: (_, child, progress) => progress == null
                    ? child
                    : const Padding(
                  padding: EdgeInsets.all(6),
                  child: CircularProgressIndicator(strokeWidth: 1.5),
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
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? XColors.primary : XColors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}