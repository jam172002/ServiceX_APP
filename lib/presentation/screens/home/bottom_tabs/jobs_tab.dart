import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:servicex_client_app/domain/models/booking_model.dart';
import 'package:servicex_client_app/presentation/screens/bookings/booking_detail_screen.dart';
import 'package:servicex_client_app/presentation/widgets/request_screen_card.dart';
import 'package:servicex_client_app/presentation/widgets/request_status_filter.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

import 'controller/jobs_tab_controller.dart';

class JobsTabScreen extends StatelessWidget {
  const JobsTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(JobsTabController());

    return Column(
      children: [
        // ── Title ──────────────────────────────────────────────────
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Align(
            alignment: Alignment.center,
            child: Text(
              'My Bookings',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: XColors.black,
              ),
            ),
          ),
        ),

        // ── Chip filter row ────────────────────────────────────────
        Obx(() => RequestStatusFilter(
          selectedStatus: c.selectedStatus.value,
          onStatusSelected: c.setFilter,
          statuses: JobsTabController.filterLabels,
        )),

        const SizedBox(height: 12),

        // ── Content ───────────────────────────────────────────────
        Expanded(
          child: Obx(() {
            if (c.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (c.error.value.isNotEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Colors.red),
                    const SizedBox(height: 12),
                    Text(
                      'Failed to load bookings',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      c.error.value,
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => c.refresh(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final items = c.filteredBookings;

            if (items.isEmpty) {
              return SizedBox(
                width: double.infinity,
                child: Align(
                  alignment: const Alignment(0, -0.5),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/no-bookings.png',
                        width: 260,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Image.asset(
                          'assets/images/No-data.png',
                          width: 260,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'No bookings here',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: XColors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => c.refresh(),
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: items.length + 1,
                itemBuilder: (_, index) {
                  if (index == items.length) {
                    return const SizedBox(height: 80);
                  }
                  final b = items[index];
                  return _BookingCard(
                    booking: b,
                    onTap: () => Get.to(() => BookingDetailScreen(booking: b)),
                  );
                },
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _BookingCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback onTap;

  const _BookingCard({required this.booking, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final b = booking;
    return RequestScreenCard(
      category: b.categoryName,
      title: b.subcategoryName,
      description: b.details,
      location: b.address,
      status: JobsTabController.statusLabel(b.status),
      jobType: b.fixerName.isNotEmpty ? b.fixerName : 'Direct Booking',
      budget: JobsTabController.budgetLabel(b.budgetMin, b.budgetMax),
      date: JobsTabController.dateLabel(b.scheduledAt),
      time: JobsTabController.timeLabel(b.scheduledAt),
      imageUrl: b.imageUrls.isNotEmpty ? b.imageUrls.first : null,
      imageAsset: null,
      additionalImages: b.imageUrls.length > 1 ? b.imageUrls.length - 1 : 0,
      onTap: onTap,
    );
  }
}