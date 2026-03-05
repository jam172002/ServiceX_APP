import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:servicex_client_app/domain/models/job_request_model.dart';
import 'package:servicex_client_app/presentation/screens/service_requests/request_detail_screen.dart';
import 'package:servicex_client_app/presentation/widgets/common_appbar.dart';
import 'package:servicex_client_app/presentation/widgets/request_screen_card.dart';
import 'package:servicex_client_app/presentation/widgets/request_status_filter.dart';

import 'controller/job_requests_controller.dart';

class VipeepRequestTab extends StatelessWidget {
  const VipeepRequestTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Lazy-put so it's created once and disposed when the screen leaves
    final controller = Get.put(JobRequestsController());

    return Scaffold(
      appBar: XAppBar(title: 'Job Requests', showBackIcon: false),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),

            // ── Status filter tabs ─────────────────────────────────
            Obx(() => RequestStatusFilter(
              selectedStatus: controller.selectedStatus.value,
              onStatusSelected: controller.setFilter,
              // Pass the real filter labels so they match JobStatus values
              statuses: JobRequestsController.filterLabels,
            )),

            const SizedBox(height: 12),

            // ── Main content ───────────────────────────────────────
            Expanded(
              child: Obx(() {
                // Loading state
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Error state
                if (controller.error.value.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 48, color: Colors.red),
                        const SizedBox(height: 12),
                        Text(
                          'Failed to load jobs',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          controller.error.value,
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: controller.refresh,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final jobs = controller.filteredJobs;

                // Empty state
                if (jobs.isEmpty) {
                  return SizedBox(
                    width: double.infinity,
                    child: Align(
                      alignment: const Alignment(0, -0.5),
                      child: Image.asset(
                        'assets/images/No-data.png',
                        width: 300,
                        height: 300,
                        fit: BoxFit.contain,
                      ),
                    ),
                  );
                }

                // Job list
                return RefreshIndicator(
                  onRefresh: controller.refresh,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: jobs.length + 1, // +1 for bottom padding item
                    itemBuilder: (context, index) {
                      if (index == jobs.length) {
                        return const SizedBox(height: 80);
                      }

                      final job = jobs[index];
                      return _JobCard(
                        job: job,
                        onTap: () => Get.to(
                              () => RequestDetailScreen(
                            isRequestDetailScreen: true,
                            // Pass job id so detail screen can load data
                            // jobId: job.id,
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

/// Adapter widget: maps [JobRequestModel] fields → [RequestScreenCard] params.
class _JobCard extends StatelessWidget {
  final JobRequestModel job;
  final VoidCallback onTap;

  const _JobCard({required this.job, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return RequestScreenCard(
      category: job.categoryName,
      title: job.subcategoryName,
      description: job.details,
      location: job.address,
      status: JobRequestsController.statusLabel(job.status),
      jobType: job.isOpenForAll ? 'Open For All' : 'Private',
      budget: JobRequestsController.budgetLabel(job.budgetMin, job.budgetMax),
      date: JobRequestsController.dateLabel(job.scheduledAt),
      time: JobRequestsController.timeLabel(job.scheduledAt),
      // First image for the card thumbnail; rest are "additional"
      imageAsset: null,
      imageUrl: job.imageUrls.isNotEmpty ? job.imageUrls.first : null,
      additionalImages:
      job.imageUrls.length > 1 ? job.imageUrls.length - 1 : 0,
      onTap: onTap,
    );
  }
}