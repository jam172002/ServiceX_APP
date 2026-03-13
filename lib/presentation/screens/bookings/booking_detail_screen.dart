import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:servicex_client_app/domain/enums/app_enums.dart';
import 'package:servicex_client_app/domain/models/booking_model.dart';
import 'package:servicex_client_app/presentation/widgets/common_appbar.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

import '../home/bottom_tabs/controller/booking_tab_controller.dart';

class BookingDetailScreen extends StatelessWidget {
  final BookingModel booking;

  const BookingDetailScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<BookingTabController>();
    final fixerName = booking.fixerName.isNotEmpty
        ? booking.fixerName
        : 'Unknown';
    final fixerImage = booking.fixerImageUrl;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: XAppBar(title: 'Booking Details'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Status banner ──────────────────────────────────
            _StatusBanner(status: booking.status),
            const SizedBox(height: 20),

            // ── Fixer card ─────────────────────────────────────
            _SectionCard(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: XColors.borderColor,
                    backgroundImage: fixerImage.isNotEmpty
                        ? NetworkImage(fixerImage)
                        : null,
                    child: fixerImage.isEmpty
                        ? const Icon(Icons.person,
                        color: Colors.grey, size: 28)
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fixerName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          booking.categoryName,
                          style: const TextStyle(
                              fontSize: 12, color: XColors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Service info ───────────────────────────────────
            _SectionLabel('Service Details'),
            _SectionCard(
              child: Column(
                children: [
                  _InfoRow(
                    icon: Iconsax.category,
                    label: 'Category',
                    value: booking.categoryName,
                  ),
                  _Divider(),
                  _InfoRow(
                    icon: Iconsax.tag,
                    label: 'Sub-Type',
                    value: booking.subcategoryName,
                  ),
                  _Divider(),
                  _InfoRow(
                    icon: Iconsax.document_text,
                    label: 'Details',
                    value: booking.details,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Schedule & Location ────────────────────────────
            _SectionLabel('Schedule & Location'),
            _SectionCard(
              child: Column(
                children: [
                  _InfoRow(
                    icon: Iconsax.calendar,
                    label: 'Date & Time',
                    value: DateFormat('dd MMM yyyy · hh:mm a')
                        .format(booking.scheduledAt),
                  ),
                  _Divider(),
                  _InfoRow(
                    icon: Iconsax.location,
                    label: 'Address',
                    value: booking.address.isNotEmpty
                        ? booking.address
                        : 'Not set',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Budget & Payment ───────────────────────────────
            _SectionLabel('Budget & Payment'),
            _SectionCard(
              child: Column(
                children: [
                  _InfoRow(
                    icon: Iconsax.dollar_circle,
                    label: 'Budget',
                    value:
                    '\$${booking.budgetMin} – \$${booking.budgetMax}',
                  ),
                  _Divider(),
                  _InfoRow(
                    icon: Iconsax.card,
                    label: 'Payment',
                    value: booking.paymentMethod,
                  ),
                ],
              ),
            ),

            // ── Images ────────────────────────────────────────
            if (booking.imageUrls.isNotEmpty) ...[
              const SizedBox(height: 16),
              _SectionLabel('Attached Images'),
              SizedBox(
                height: 90,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: booking.imageUrls.length,
                  separatorBuilder: (_, __) =>
                  const SizedBox(width: 10),
                  itemBuilder: (_, i) => ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      booking.imageUrls[i],
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 90,
                        height: 90,
                        color: XColors.borderColor,
                        child: const Icon(Icons.broken_image,
                            color: XColors.grey),
                      ),
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 28),

            // ── Action buttons ─────────────────────────────────
            _ActionButtons(booking: booking, c: c),
          ],
        ),
      ),
    );
  }
}

// ── Status Banner ─────────────────────────────────────────────────
class _StatusBanner extends StatelessWidget {
  final BookingStatus status;
  const _StatusBanner({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(_icon, color: _color, size: 18),
          const SizedBox(width: 10),
          Text(
            _label,
            style: TextStyle(
              color: _color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Color get _color {
    switch (status) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.accepted:
        return Colors.blue;
      case BookingStatus.inProgress:
        return Colors.purple;
      case BookingStatus.completed:
        return Colors.teal;
      case BookingStatus.cancelled:
        return Colors.red;
      case BookingStatus.booked:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  IconData get _icon {
    switch (status) {
      case BookingStatus.pending:
        return Iconsax.clock;
      case BookingStatus.accepted:
        return Iconsax.tick_circle;
      case BookingStatus.inProgress:
        return Iconsax.refresh_circle;
      case BookingStatus.completed:
        return Iconsax.medal_star;
      case BookingStatus.cancelled:
        return Iconsax.close_circle;
      case BookingStatus.booked:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  String get _label {
    switch (status) {
      case BookingStatus.pending:
        return 'Awaiting acceptance from fixer';
      case BookingStatus.accepted:
        return 'Fixer has accepted your booking';
      case BookingStatus.inProgress:
        return 'Work is in progress';
      case BookingStatus.completed:
        return 'Booking completed';
      case BookingStatus.cancelled:
        return 'Booking was cancelled';
      case BookingStatus.booked:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }
}

// ── Action Buttons ────────────────────────────────────────────────
class _ActionButtons extends StatelessWidget {
  final BookingModel booking;
  final BookingTabController c;

  const _ActionButtons({required this.booking, required this.c});

  @override
  Widget build(BuildContext context) {
    switch (booking.status) {
      case BookingStatus.pending:
        return _pendingActions(context);
      case BookingStatus.accepted:
      case BookingStatus.inProgress:
        return _acceptedActions(context);
      case BookingStatus.completed:
        return _completedActions(context);
      case BookingStatus.cancelled:
        return _cancelledActions(context);
      case BookingStatus.booked:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  // ── Pending: Cancel + Resend ──────────────────────────────────
  Widget _pendingActions(BuildContext context) {
    return Column(
      children: [
        _PrimaryButton(
          label: 'Cancel Booking',
          color: Colors.red,
          icon: Iconsax.close_circle,
          onTap: () => _confirmCancel(context),
        ),
        const SizedBox(height: 10),
        _SecondaryButton(
          label: 'Edit & Resend',
          icon: Iconsax.edit,
          onTap: () {
            // Go back and re-open booking screen for same fixer
            Get.back();
            // The caller can re-navigate; we just cancel & pop here
          },
        ),
      ],
    );
  }

  // ── Accepted / In Progress: Mark Complete ─────────────────────
  Widget _acceptedActions(BuildContext context) {
    return _PrimaryButton(
      label: 'Mark as Complete',
      color: Colors.teal,
      icon: Iconsax.tick_circle,
      onTap: () => _confirmComplete(context),
    );
  }

  // ── Completed: Leave Review (if not yet reviewed) ─────────────
  Widget _completedActions(BuildContext context) {
    return _PrimaryButton(
      label: 'Leave a Review',
      color: XColors.primary,
      icon: Iconsax.star,
      onTap: () => _showReviewSheet(context),
    );
  }

  // ── Cancelled ─────────────────────────────────────────────────
  Widget _cancelledActions(BuildContext context) {
    return _PrimaryButton(
      label: 'Book Again',
      color: XColors.primary,
      icon: Iconsax.refresh,
      onTap: () {
        Get.back();
        // Navigate to CreateBookingScreen — caller should handle
      },
    );
  }

  // ── Dialogs ───────────────────────────────────────────────────
  void _confirmCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Cancel Booking',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        content: const Text(
            'Are you sure you want to cancel this booking?',
            style: TextStyle(fontSize: 13, color: XColors.grey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('No',
                style: TextStyle(color: XColors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await c.cancelBooking(booking.id);
              Get.back();
              Get.snackbar('Cancelled',
                  'Your booking has been cancelled.');
            },
            child: const Text('Yes, Cancel',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _confirmComplete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Mark Complete',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        content: const Text(
            'Confirm the work has been completed?',
            style: TextStyle(fontSize: 13, color: XColors.grey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Not yet',
                style: TextStyle(color: XColors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await c.markComplete(booking.id);
              Get.back();
              Get.snackbar(
                  'Completed', 'Booking marked as complete!');
            },
            child: Text('Confirm',
                style: TextStyle(color: Colors.teal)),
          ),
        ],
      ),
    );
  }

  void _showReviewSheet(BuildContext context) {
    double rating = 0;
    final reviewCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: StatefulBuilder(
          builder: (ctx, setS) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Leave a Review',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              const Text(
                'How was your experience with the fixer?',
                style: TextStyle(fontSize: 12, color: XColors.grey),
              ),
              const SizedBox(height: 20),

              // Star rating row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final filled = i < rating;
                  return GestureDetector(
                    onTap: () => setS(() => rating = i + 1.0),
                    child: Padding(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(
                        filled ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        size: 38,
                        color: filled
                            ? XColors.warning
                            : XColors.borderColor,
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 20),

              // Review text field
              TextField(
                controller: reviewCtrl,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Write your review here…',
                  hintStyle: const TextStyle(
                      fontSize: 12, color: XColors.grey),
                  contentPadding: const EdgeInsets.all(14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                    BorderSide(color: XColors.borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                    BorderSide(color: XColors.primary),
                  ),
                  filled: true,
                  fillColor: XColors.secondaryBG,
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (rating == 0) {
                      Get.snackbar(
                          'Rating required', 'Please select a star rating.');
                      return;
                    }
                    Navigator.pop(ctx);
                    await c.submitReview(
                      bookingId: booking.id,
                      fixerId: booking.fixerId,
                      rating: rating,
                      review: reviewCtrl.text.trim(),
                    );
                    Get.snackbar(
                        'Thank you!', 'Your review has been submitted.');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: XColors.primary,
                    padding:
                    const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text(
                    'Submit Review',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Reusable layout helpers ───────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: XColors.black),
    ),
  );
}

class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: XColors.secondaryBG,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: XColors.borderColor),
    ),
    child: child,
  );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: XColors.grey),
        const SizedBox(width: 10),
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(
                fontSize: 12,
                color: XColors.grey,
                fontWeight: FontWeight.w400),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
                fontSize: 12,
                color: XColors.black,
                fontWeight: FontWeight.w500),
          ),
        ),
      ],
    ),
  );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Divider(height: 1, color: XColors.borderColor);
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;
  const _PrimaryButton(
      {required this.label,
        required this.color,
        required this.icon,
        required this.onTap});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16, color: Colors.white),
      label: Text(
        label,
        style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
      ),
    ),
  );
}

class _SecondaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _SecondaryButton(
      {required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16, color: XColors.primary),
      label: Text(
        label,
        style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: XColors.primary),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: const BorderSide(color: XColors.primary),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
      ),
    ),
  );
}