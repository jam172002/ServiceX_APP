import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:servicex_client_app/domain/enums/app_enums.dart';
import 'package:servicex_client_app/domain/models/booking_model.dart';
import 'package:servicex_client_app/presentation/widgets/booking_card_widget.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';
import 'package:servicex_client_app/utils/helpers/helper_functions.dart';

import '../../bookings/booking_detail_screen.dart';
import 'controller/jobs_tab_controller.dart';

class JobsTabScreen extends StatefulWidget {
  const JobsTabScreen({super.key});

  @override
  State<JobsTabScreen> createState() => _JobsTabScreenState();
}

class _JobsTabScreenState extends State<JobsTabScreen>
    with SingleTickerProviderStateMixin {
  late final JobsTabController _c;
  late final TabController _tabController;

  final List<String> _tabs = [
    'All',
    'Pending',
    'Accepted',
    'In Progress',
    'Completed',
    'Cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _c = Get.put(JobsTabController());
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    Get.delete<JobsTabController>();
    super.dispose();
  }

  List<BookingModel> _filtered(List<BookingModel> all, int tabIndex) {
    if (tabIndex == 0) return all;
    final map = {
      1: BookingStatus.pending,
      2: BookingStatus.accepted,
      3: BookingStatus.inProgress,
      4: BookingStatus.completed,
      5: BookingStatus.cancelled,
    };
    return all.where((b) => b.status == map[tabIndex]).toList();
  }

  @override
  Widget build(BuildContext context) {
    final width = XHelperFunctions.screenWidth();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ── Tab bar ─────────────────────────────────────────
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: XColors.primary,
              unselectedLabelColor: XColors.grey,
              labelStyle: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600),
              unselectedLabelStyle: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w400),
              indicatorColor: XColors.primary,
              indicatorWeight: 2.5,
              dividerColor: XColors.borderColor,
              tabs: _tabs.map((t) => Tab(text: t)).toList(),
            ),
          ),

          // ── Content ─────────────────────────────────────────
          Expanded(
            child: Obx(() {
              if (_c.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (_c.error.value.isNotEmpty) {
                return Center(
                  child: Text(
                    _c.error.value,
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              return TabBarView(
                controller: _tabController,
                children: List.generate(_tabs.length, (tabIndex) {
                  final items = _filtered(_c.bookings.toList(), tabIndex);

                  if (items.isEmpty) {
                    return _buildEmptyState(width);
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    itemCount: items.length,
                    itemBuilder: (_, i) {
                      final b = items[i];
                      return BookingCard(
                        booking: b,
                        fixerName: b.fixerName,
                        fixerImageUrl: b.fixerImageUrl,
                        onTap: () => Get.to(
                              () => BookingDetailScreen(booking: b),
                        ),
                      );
                    },
                  );
                }),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(double width) {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Column(
        children: [
          Image.asset(
            'assets/images/no-bookings.png',
            width: width * 0.65,
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
    );
  }
}