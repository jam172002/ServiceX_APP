import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:servicex_client_app/domain/models/job_request_model.dart';
import 'package:servicex_client_app/presentation/screens/service_requests/job_detail_screen.dart';
import 'package:servicex_client_app/presentation/widgets/job_screen_card.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

import '../../service_requests/quotes/quotes_list_screen.dart';
import 'controller/job_controller.dart';

class JobTab extends StatelessWidget {
  const JobTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(JobController());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('Job Requests',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: XColors.black)),
        actions: [
          Obx(() {
            final isFiltered = controller.selectedStatus.value != 'All';
            return Stack(clipBehavior: Clip.none, children: [
              IconButton(
                icon: Icon(Iconsax.filter,
                    color: isFiltered ? XColors.primary : XColors.grey, size: 22),
                onPressed: () => _showFilterSheet(context, controller),
              ),
              if (isFiltered)
                Positioned(
                  top: 10, right: 10,
                  child: Container(
                    width: 7, height: 7,
                    decoration: const BoxDecoration(
                        color: XColors.primary, shape: BoxShape.circle),
                  ),
                ),
            ]);
          }),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.error.value.isNotEmpty) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 12),
                Text('Failed to load jobs', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(controller.error.value,
                    style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                    onPressed: controller.refresh,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry')),
              ]),
            );
          }

          final jobs = controller.filteredJobs;

          return Column(children: [
            // Active filter chip
            if (controller.selectedStatus.value != 'All')
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: XColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(controller.selectedStatus.value,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600, color: XColors.primary)),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => controller.setFilter('All'),
                        child: const Icon(Icons.close, size: 14, color: XColors.primary),
                      ),
                    ]),
                  ),
                ]),
              ),

            Expanded(
              child: jobs.isEmpty
                  ? SizedBox(
                width: double.infinity,
                child: Align(
                  alignment: const Alignment(0, -0.5),
                  child: Image.asset('assets/images/No-data.png',
                      width: 300, height: 300, fit: BoxFit.contain),
                ),
              )
                  : RefreshIndicator(
                onRefresh: controller.refresh,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: jobs.length + 1,
                  itemBuilder: (context, index) {
                    if (index == jobs.length) return const SizedBox(height: 80);
                    final job = jobs[index];
                    return _JobCard(
                      job: job,
                      onTap: () => Get.to(() => JobDetailScreen(
                          isRequestDetailScreen: true, jobId: job.id)),
                      onQuotesTap: () => Get.to(() => QuotesListScreen(job: job)),
                    );
                  },
                ),
              ),
            ),
          ]);
        }),
      ),
    );
  }

  void _showFilterSheet(BuildContext context, JobController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Obx(() => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: XColors.grey.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Filter by Status',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: XColors.black)),
          const SizedBox(height: 16),
          ...JobController.filterLabels.map((label) => _FilterTile(
            label: label,
            isSelected: controller.selectedStatus.value == label,
            onTap: () {
              controller.setFilter(label);
              Get.back();
            },
          )),
        ]),
      )),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Filter tile
// ─────────────────────────────────────────────────────────────────────────────

class _FilterTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterTile({required this.label, required this.isSelected, required this.onTap});

  Color _labelColor(String s) {
    switch (s.toLowerCase()) {
      case 'all':       return XColors.primary;
      case 'booked':    return Colors.green;
      case 'cancelled': return Colors.red;
      case 'draft':     return Colors.orange;
      default:          return XColors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _labelColor(label);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: isSelected
                  ? color.withValues(alpha: 0.4)
                  : XColors.borderColor.withValues(alpha: 0.3)),
        ),
        child: Row(children: [
          Container(
            width: 10, height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Text(label,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? color : XColors.black)),
          const Spacer(),
          if (isSelected) Icon(Icons.check, size: 16, color: color),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Job card with quotes button
// ─────────────────────────────────────────────────────────────────────────────

class _JobCard extends StatelessWidget {
  final JobRequestModel job;
  final VoidCallback onTap;
  final VoidCallback onQuotesTap;

  const _JobCard(
      {required this.job, required this.onTap, required this.onQuotesTap});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      JobScreenCard(
        category:        job.categoryName,
        title:           job.subcategoryName,
        description:     job.details,
        location:        job.address,
        status:          JobController.statusLabel(job.status),
        jobType:         job.isOpenForAll ? 'Open For All' : 'Private',
        budget:          JobController.budgetLabel(job.budgetMin, job.budgetMax),
        date:            JobController.dateLabel(job.scheduledAt),
        time:            JobController.timeLabel(job.scheduledAt),
        imageAsset:      null,
        imageUrl:        job.imageUrls.isNotEmpty ? job.imageUrls.first : null,
        additionalImages: job.imageUrls.length > 1 ? job.imageUrls.length - 1 : 0,
        onTap:           onTap,
      ),
      // Quotes button below card
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 4),
        child: GestureDetector(
          onTap: onQuotesTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 9),
            decoration: BoxDecoration(
              color: XColors.primary.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
              border: Border.all(color: XColors.primary.withValues(alpha: 0.2)),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Iconsax.document_text, size: 15, color: XColors.primary),
              const SizedBox(width: 6),
              const Text('View Quotes',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: XColors.primary)),
            ]),
          ),
        ),
      ),
    ]);
  }
}