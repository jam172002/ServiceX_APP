import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:servicex_client_app/domain/models/job_request_model.dart';
import 'package:servicex_client_app/presentation/screens/service_requests/controller/job_detail_controller.dart';
import 'package:servicex_client_app/presentation/screens/service_requests/quotes/quotes_list_screen.dart';
import 'package:servicex_client_app/presentation/widgets/common_appbar.dart';
import 'package:servicex_client_app/presentation/widgets/reject_offer_dialog.dart';
import 'package:servicex_client_app/presentation/screens/service_requests/create_job_screen.dart';
import 'package:servicex_client_app/presentation/screens/service_provider_profile/service_provider_profile_screen.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

class JobDetailScreen extends StatelessWidget {
  final bool isRequestDetailScreen;
  final String jobId;

  const JobDetailScreen({
    super.key,
    required this.isRequestDetailScreen,
    required this.jobId,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(JobDetailController(jobId: jobId), tag: jobId);

    return Obx(() {
      if (controller.isLoading.value) {
        return Scaffold(
          appBar: XAppBar(
              title: isRequestDetailScreen ? 'Request Details' : 'Booking Details'),
          body: const Center(child: CircularProgressIndicator()),
        );
      }
      if (controller.error.value.isNotEmpty) {
        return Scaffold(
          appBar: XAppBar(title: 'Error'),
          body: Center(child: Text(controller.error.value)),
        );
      }
      final job = controller.job.value;
      if (job == null) {
        return Scaffold(
          appBar: XAppBar(title: 'Not Found'),
          body: const Center(child: Text('Job request not found.')),
        );
      }
      return _DetailBody(
          controller: controller, job: job, isRequestDetailScreen: isRequestDetailScreen);
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _DetailBody extends StatelessWidget {
  final JobDetailController controller;
  final JobRequestModel job;
  final bool isRequestDetailScreen;

  const _DetailBody(
      {required this.controller, required this.job, required this.isRequestDetailScreen});

  String get _statusKey => JobDetailController.statusKey(job.status);
  bool _isConfirmed()   => ['accepted', 'booked', 'rebooked'].contains(_statusKey);
  bool _showCancelButton() => [
    'pending', 'new', 'under_review', 'inprogress', 'accepted', 'booked', 'rebooked',
  ].contains(_statusKey);

  Color _statusColor(String key) {
    switch (key) {
      case 'new':            return Colors.blue;
      case 'under_review':   return Colors.orange;
      case 'accepted':
      case 'booked':
      case 'rebooked':       return Colors.green;
      case 'pending':        return Colors.orange;
      case 'inprogress':     return Colors.purple;
      case 'completed':      return Colors.teal;
      case 'cancelled_by_me':
      case 'cancelled_by_sp':return Colors.red;
      default:               return Colors.grey;
    }
  }

  Widget _divider() => const Column(children: [
    SizedBox(height: 6),
    Divider(color: Color(0x4D9E9E9E), height: 0.2),
    SizedBox(height: 6),
  ]);

  Widget _sectionDivider() => Column(children: [
    const SizedBox(height: 12),
    Divider(color: XColors.borderColor, height: 0.2),
    const SizedBox(height: 12),
  ]);

  @override
  Widget build(BuildContext context) {
    final statusKey   = _statusKey;
    final statusColor = _statusColor(statusKey);
    final statusText  = JobDetailController.statusText(statusKey);

    return Scaffold(
      appBar: XAppBar(
          title: isRequestDetailScreen ? 'Request Details' : 'Booking Details'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // ── Hero image ──────────────────────────────────────────────────
            Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: XColors.grey.withValues(alpha: 0.15)),
              clipBehavior: Clip.antiAlias,
              child: job.imageUrls.isNotEmpty
                  ? Image.network(job.imageUrls.first, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                  const Icon(Icons.image_not_supported_outlined,
                      size: 48, color: Colors.grey))
                  : const Icon(Icons.image_not_supported_outlined,
                  size: 48, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // ── Title & category ────────────────────────────────────────────
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(
                child: Text(job.subcategoryName,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
              ),
              Text(job.categoryName,
                  style: const TextStyle(
                      color: XColors.primary, fontSize: 13, fontWeight: FontWeight.bold)),
            ]),

            _sectionDivider(),

            // ── View Quotes button (shown when status is new/pending/underReview) ──
            if (['new', 'pending', 'under_review'].contains(statusKey)) ...[
              GestureDetector(
                onTap: () => Get.to(() => QuotesListScreen(job: job)),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        XColors.primary.withValues(alpha: 0.12),
                        XColors.primary.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: XColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Row(children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: XColors.primary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Iconsax.document_text,
                          size: 16, color: XColors.primary),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('View Quotes',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: XColors.primary)),
                        Text('See all quotes sent by service providers',
                            style: TextStyle(fontSize: 11, color: XColors.grey)),
                      ]),
                    ),
                    const Icon(Icons.arrow_forward_ios,
                        size: 14, color: XColors.primary),
                  ]),
                ),
              ),
              _sectionDivider(),
            ],

            // ── Description ─────────────────────────────────────────────────
            const Text('Description:',
                style: TextStyle(color: XColors.black, fontSize: 14, fontWeight: FontWeight.w500)),
            Text(job.details,
                textAlign: TextAlign.justify,
                style: const TextStyle(
                    color: XColors.grey, fontSize: 12, fontWeight: FontWeight.w300)),

            _sectionDivider(),

            // ── Service provider (when confirmed) ───────────────────────────
            if (_isConfirmed() ||
                ['inprogress', 'completed', 'cancelled_by_sp'].contains(statusKey))
              _ServiceProviderSection(divider: _sectionDivider),

            // ── Status badge ────────────────────────────────────────────────
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Status',
                  style: TextStyle(color: XColors.black, fontSize: 14, fontWeight: FontWeight.w500)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4)),
                child: Text(statusText,
                    style: TextStyle(
                        fontSize: 11, color: statusColor, fontWeight: FontWeight.w600)),
              ),
            ]),

            _sectionDivider(),

            // ── Cancellation reason ─────────────────────────────────────────
            if (['cancelled_by_me', 'cancelled_by_sp'].contains(statusKey))
              _CancelledSection(statusKey: statusKey, divider: _sectionDivider),

            // ── Payment method ──────────────────────────────────────────────
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Payment Method',
                  style: TextStyle(color: XColors.black, fontSize: 14, fontWeight: FontWeight.w500)),
              Text(job.paymentMethod,
                  style: const TextStyle(
                      color: XColors.grey, fontSize: 12, fontWeight: FontWeight.w300)),
            ]),

            _sectionDivider(),

            // ── Location ────────────────────────────────────────────────────
            Row(children: [
              const Icon(Iconsax.location, color: XColors.primary, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(job.address.isNotEmpty ? job.address : 'Not specified',
                    style: const TextStyle(
                        color: XColors.grey, fontSize: 12, fontWeight: FontWeight.w300)),
              ),
            ]),
            const SizedBox(height: 8),

            // ── Scheduled date & time ───────────────────────────────────────
            Row(children: [
              const Icon(Iconsax.calendar_1, color: XColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                '${JobDetailController.formatDate(job.scheduledAt)} / ${JobDetailController.formatTime(job.scheduledAt)}',
                style: const TextStyle(
                    color: XColors.grey, fontSize: 12, fontWeight: FontWeight.w300),
              ),
            ]),

            if (_isConfirmed() || ['inprogress', 'completed'].contains(statusKey)) ...[
              const SizedBox(height: 8),
              const Row(children: [
                Icon(Iconsax.clock, color: XColors.primary, size: 18),
                SizedBox(width: 8),
                Text('Estimated Time: TBD',
                    style: TextStyle(
                        color: XColors.grey, fontSize: 12, fontWeight: FontWeight.w300)),
              ]),
            ],

            _sectionDivider(),

            // ── Photos ──────────────────────────────────────────────────────
            const Text('Photos',
                style: TextStyle(color: XColors.black, fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            job.imageUrls.isEmpty
                ? const Text('No photos attached.',
                style: TextStyle(color: XColors.grey, fontSize: 12))
                : SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: job.imageUrls.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) => ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    job.imageUrls[i],
                    width: 90, height: 90, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 90, height: 90,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ),

            _sectionDivider(),

            // ── Price details ───────────────────────────────────────────────
            const Text('Price Details',
                style: TextStyle(color: XColors.black, fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            _PriceSection(
                job: job, statusKey: statusKey, isConfirmed: _isConfirmed(), divider: _divider),

            const SizedBox(height: 40),

            // ── Cancel button ───────────────────────────────────────────────
            if (_showCancelButton())
              Obx(() => controller.isCancelling.value
                  ? const Center(child: CircularProgressIndicator())
                  : OutlinedButton.icon(
                onPressed: () => Get.dialog(RejectDialog(
                  title: 'Cancel Request',
                  subtitle: 'Please provide a reason for cancellation.',
                  hintText: 'Write your reason...',
                  onSubmit: (reason) => controller.cancelJob(reason),
                )),
                icon: const Icon(Icons.clear, color: XColors.danger),
                label: const Text('Cancel Request',
                    style: TextStyle(
                        fontWeight: FontWeight.w300, fontSize: 13, color: XColors.danger)),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(45),
                  side: const BorderSide(color: XColors.danger),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              )),

            const SizedBox(height: 10),

            // ── Action button ───────────────────────────────────────────────
            if (statusKey != 'pending') ...[
              if (statusKey == 'new')
                ActionBtn(
                  text: 'View Quotes',
                  onTap: () => Get.to(() => QuotesListScreen(job: job)),
                )
              else if (statusKey == 'completed' || statusKey == 'cancelled_by_sp')
                ActionBtn(
                  text: 'Rebook',
                  onTap: () =>
                      Get.to(() => CreateServiceJobScreen(showServiceProviderCard: true)),
                )
              else if (statusKey == 'inprogress' || _isConfirmed())
                  ActionBtn(text: 'Mark as Finished', onTap: () {}),
            ],
          ]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets (unchanged from original except _ServiceProviderSection is dummy)
// ─────────────────────────────────────────────────────────────────────────────

class _ServiceProviderSection extends StatelessWidget {
  final Widget Function() divider;
  const _ServiceProviderSection({required this.divider});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Service Provider',
          style: TextStyle(color: XColors.black, fontSize: 14, fontWeight: FontWeight.w500)),
      const SizedBox(height: 8),
      Row(children: [
        const CircleAvatar(
          radius: 35,
          backgroundImage: AssetImage('assets/images/service_provider.png'),
        ),
        const SizedBox(width: 8),
        const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Assigned Provider',
              style: TextStyle(color: XColors.black, fontSize: 14, fontWeight: FontWeight.w500)),
          Text('Service Professional',
              style: TextStyle(color: XColors.grey, fontSize: 12, fontWeight: FontWeight.w300)),
        ]),
        const Spacer(),
        IconButton.filled(
          onPressed: () => Get.to(() => ServiceProviderProfileScreen()),
          icon: const Icon(Iconsax.user, color: XColors.primary, size: 18),
          style: IconButton.styleFrom(
              backgroundColor: XColors.primary.withValues(alpha: 0.2)),
        ),
        IconButton.filled(
          onPressed: () {},
          icon: const Icon(Iconsax.sms, color: XColors.primary, size: 18),
          style: IconButton.styleFrom(
              backgroundColor: XColors.primary.withValues(alpha: 0.2)),
        ),
      ]),
      divider(),
    ]);
  }
}

class _CancelledSection extends StatelessWidget {
  final String statusKey;
  final Widget Function() divider;
  const _CancelledSection({required this.statusKey, required this.divider});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Cancelled By:',
            style: TextStyle(color: XColors.black, fontSize: 13, fontWeight: FontWeight.w500)),
        Text(statusKey == 'cancelled_by_me' ? 'You' : 'Service Provider',
            style: const TextStyle(color: XColors.grey, fontSize: 12, fontWeight: FontWeight.w500)),
      ]),
      const SizedBox(height: 4),
      Text('Cancellation reason will appear here.',
          textAlign: TextAlign.justify,
          style: TextStyle(color: XColors.danger.withValues(alpha: 0.7), fontSize: 12)),
      divider(),
    ]);
  }
}

class _PriceSection extends StatelessWidget {
  final JobRequestModel job;
  final String statusKey;
  final bool isConfirmed;
  final Widget Function() divider;

  const _PriceSection(
      {required this.job, required this.statusKey,
        required this.isConfirmed, required this.divider});

  @override
  Widget build(BuildContext context) {
    final showBudget = ['new', 'under_review', 'cancelled_by_me', 'pending'].contains(statusKey);
    final showPrice  = isConfirmed || ['inprogress', 'completed', 'cancelled_by_sp'].contains(statusKey);
    final showCommission = ['inprogress', 'completed', 'cancelled_by_sp'].contains(statusKey);
    final showTotal  = statusKey == 'completed';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: XColors.lightTint.withValues(alpha: 0.5)),
      child: Column(children: [
        if (showBudget) _row('Budget', '\$${job.budgetMin} - \$${job.budgetMax}'),
        if (showPrice) ...[
          if (showBudget) divider(),
          _row('Price', '\$${job.budgetMax}'),
        ],
        if (showCommission) ...[
          divider(),
          _row('Commission (10%)', '\$${(job.budgetMax * 0.1).toStringAsFixed(0)}'),
        ],
        if (showTotal) ...[
          divider(),
          _row('Total', '\$${(job.budgetMax * 1.1).toStringAsFixed(0)}', highlight: true),
        ],
      ]),
    );
  }

  Widget _row(String label, String value, {bool highlight = false}) {
    final color = highlight ? XColors.primary : XColors.black;
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label,
          style: TextStyle(
              color: color, fontSize: highlight ? 14 : 13,
              fontWeight: highlight ? FontWeight.bold : FontWeight.w500)),
      Text(value,
          style: TextStyle(
              color: highlight ? XColors.primary : XColors.grey,
              fontSize: highlight ? 13 : 12,
              fontWeight: highlight ? FontWeight.bold : FontWeight.w500)),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class ActionBtn extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const ActionBtn({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: XColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(text, style: const TextStyle(fontSize: 14, color: Colors.white)),
      ),
    );
  }
}