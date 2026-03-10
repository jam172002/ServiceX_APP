import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:servicex_client_app/domain/models/fixer_model.dart';
import 'package:servicex_client_app/domain/models/location_model.dart';
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
import 'package:servicex_client_app/presentation/screens/chat/single_chat_screen.dart';
import 'package:servicex_client_app/presentation/screens/chat/controller/chat_controller.dart';
import 'package:servicex_client_app/services/chat_notification_service.dart';

/// Navigate here from a fixer profile or service-providers list:
///
/// ```dart
/// Get.to(() => CreateBookingScreen(
///   fixer: fixer,
///   fixerCategoryName: widget.sub.name, // optional — auto-selects chip
/// ));
/// ```
class CreateBookingScreen extends StatefulWidget {
  final FixerModel fixer;

  /// If provided, the matching category chip is auto-selected on load.
  final String? fixerCategoryName;

  const CreateBookingScreen({
    super.key,
    required this.fixer,
    this.fixerCategoryName,
  });

  @override
  State<CreateBookingScreen> createState() => _CreateBookingScreenState();
}

class _CreateBookingScreenState extends State<CreateBookingScreen> {
  late final CreateBookingController _c;
  bool _isChatLoading = false;

  @override
  void initState() {
    super.initState();
    _c = Get.put(CreateBookingController());

    _c.fixer = widget.fixer;
    _c.loadFixerSubcategories();
  }

  // ── Open chat ──────────────────────────────────────────────────
  Future<void> _openChat() async {
    final f = widget.fixer;

    if (f.uid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Provider info not available')),
      );
      return;
    }

    setState(() => _isChatLoading = true);

    try {
      if (!Get.isRegistered<ChatController>()) {
        Get.put(ChatController());
      }

      final ctrl = Get.find<ChatController>();
      final myToken = await ChatNotificationService.instance.getToken();

      await ctrl.openChat(
        otherId: f.uid,
        otherName: f.fullName,
        otherAvatar: f.profileImageUrl,
        otherFcmToken: f.fcmToken,
        myFcmToken: myToken,
      );

      if (!mounted) return;

      Get.to(() => SingleChatScreen(
        conversationId: ctrl.activeConversationId.value,
        otherUserId: f.uid,
        otherUserName: f.fullName,
        otherUserAvatar: f.profileImageUrl,
        isServiceProvider: false,
      ));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _isChatLoading = false);
    }
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
                    'Booking sent to ${widget.fixer.fullName}!',
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

            // ── Category (fixed — from fixer profile) ─────────
            _buildFixedCategoryRow(),

            const SizedBox(height: 12),

            // ── Sub-Type dropdown (fixer's subcategories only) ─
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
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: XColors.secondaryBG,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: XColors.borderColor),
          ),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 28,
                backgroundImage: widget.fixer.profileImageUrl.isNotEmpty
                    ? NetworkImage(widget.fixer.profileImageUrl) as ImageProvider
                    : AssetImage(XImages.serviceProvider),
              ),
              const SizedBox(width: 12),
              // Name + category
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.fixer.fullName,
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
                onPressed: () => Get.to(
                      () => ServiceProviderProfileScreen(),
                  arguments: widget.fixer,
                ),
                icon: const Icon(Iconsax.user, size: 18),
                style: IconButton.styleFrom(
                  backgroundColor: XColors.primary.withValues(alpha: 0.2),
                  foregroundColor: XColors.primary,
                ),
              ),
              // Message
              IconButton.filled(
                onPressed: _isChatLoading ? null : _openChat,
                icon: _isChatLoading
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: XColors.primary,
                  ),
                )
                    : const Icon(Iconsax.sms, size: 18),
                style: IconButton.styleFrom(
                  backgroundColor: XColors.primary.withValues(alpha: 0.2),
                  foregroundColor: XColors.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // ── Fixed category display (not selectable) ─────────────────
  Widget _buildFixedCategoryRow() {
    // categoryName is resolved once after loadFixerSubcategories completes.
    // Wrap in Obx via subcategoriesLoading so it redraws when loading finishes.
    return Obx(() {
      final categoryName = _c.subcategoriesLoading.value
          ? widget.fixer.mainCategory
          : _c.fixerCategoryName.value.isNotEmpty
          ? _c.fixerCategoryName.value
          : widget.fixer.mainCategory;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Service Type',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: XColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: XColors.primary, width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.build_outlined, size: 16, color: XColors.primary),
                const SizedBox(width: 8),
                Text(
                  categoryName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: XColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.lock_outline, size: 13, color: XColors.primary),
              ],
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

      return DropdownButtonFormField<String>(
        initialValue: _c.selectedSubcategory.value?.id,
        hint: Text(
          isLoading
              ? 'Loading…'
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
        onChanged: (!isLoading && subs.isNotEmpty)
            ? (val) {
          final sub = subs.firstWhereOrNull((s) => s.id == val);
          if (sub != null) _c.selectSubcategory(sub);
        }
            : null,
      );
    });
  }
}