import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:servicex_client_app/common/widgets/appbar/common_appbar.dart';
import 'package:servicex_client_app/common/widgets/containers/search_filter_container.dart';
import 'package:servicex_client_app/features/service/screens/home/linked_screens/fixxer_job_detail_screen.dart';
import 'package:servicex_client_app/features/service/screens/requests/widgets/fixxers/fixxer_job_request_card.dart';
import 'package:servicex_client_app/features/service/screens/requests/widgets/fixxers/fixxer_request_filter_sheet.dart';
import 'package:servicex_client_app/features/service/screens/requests/widgets/fixxers/fixxer_request_type_chip.dart';
import 'package:servicex_client_app/utils/constants/enums.dart';
import 'package:servicex_client_app/features/service/models/fixxer_job_request_model.dart';

/// =======================
/// SCREEN
/// =======================
class FixxerRequestScreen extends StatefulWidget {
  const FixxerRequestScreen({super.key});

  @override
  State<FixxerRequestScreen> createState() => _FixxerRequestScreenState();
}

class _FixxerRequestScreenState extends State<FixxerRequestScreen> {
  final TextEditingController _searchController = TextEditingController();

  /// Tabs
  FixxerRequestTypeTab selectedTab = FixxerRequestTypeTab.all;

  /// Filters
  RangeValues budgetRange = const RangeValues(0, 1000);
  DateTimeRange? selectedDateRange;

  late final List<FixxerJobRequestModel> allRequests;
  List<FixxerJobRequestModel> filteredRequests = [];

  @override
  void initState() {
    super.initState();
    allRequests = _dummyRequests();
    filteredRequests = allRequests;
  }

  /// =======================
  /// FILTER LOGIC
  /// =======================
  void applyFilters() {
    setState(() {
      final query = _searchController.text.toLowerCase();

      filteredRequests = allRequests.where((job) {
        final matchesSearch =
            query.isEmpty ||
            job.clientName.toLowerCase().contains(query) ||
            job.serviceTitle.toLowerCase().contains(query) ||
            job.location.toLowerCase().contains(query);

        final matchesType =
            selectedTab == FixxerRequestTypeTab.all ||
            (selectedTab == FixxerRequestTypeTab.direct &&
                job.type == FixxerJobRequestType.direct) ||
            (selectedTab == FixxerRequestTypeTab.open &&
                job.type == FixxerJobRequestType.open);

        final matchesBudget =
            job.minBudget >= budgetRange.start &&
            job.maxBudget <= budgetRange.end;

        final matchesDate =
            selectedDateRange == null ||
            (job.dateTime.isAfter(
                  selectedDateRange!.start.subtract(const Duration(seconds: 1)),
                ) &&
                job.dateTime.isBefore(
                  selectedDateRange!.end.add(const Duration(seconds: 1)),
                ));

        return matchesSearch && matchesType && matchesBudget && matchesDate;
      }).toList();
    });
  }

  /// =======================
  /// UI
  /// =======================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: XAppBar(title: 'Job Requests', showBackIcon: false),
      body: Column(
        children: [
          /// SEARCH + FILTER
          SearchWithFilter(
            horPadding: 12,
            controller: _searchController,
            onChanged: (_) => applyFilters(),
            onFilterTap: () {
              fixxerRequestFilterSheet(
                context: context,
                budgetRange: budgetRange,
                onBudgetChanged: (val) => setState(() => budgetRange = val),
                selectedDateRange: selectedDateRange,
                onDateRangeChanged: (val) =>
                    setState(() => selectedDateRange = val),
                onClear: () {
                  setState(() {
                    budgetRange = const RangeValues(0, 1000);
                    selectedDateRange = null;
                    _searchController.clear();
                    filteredRequests = allRequests;
                  });
                },
                onApply: applyFilters,
                maxDistance: 0,
                onDistanceChanged: (double value) {},
              );
            },
          ),

          const SizedBox(height: 12),

          /// TOP TABS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                FixxerRequestTypeChip(
                  label: 'All',
                  isSelected: selectedTab == FixxerRequestTypeTab.all,
                  onTap: () {
                    setState(() => selectedTab = FixxerRequestTypeTab.all);
                    applyFilters();
                  },
                ),
                const SizedBox(width: 8),
                FixxerRequestTypeChip(
                  label: 'Direct',
                  isSelected: selectedTab == FixxerRequestTypeTab.direct,
                  onTap: () {
                    setState(() => selectedTab = FixxerRequestTypeTab.direct);
                    applyFilters();
                  },
                ),
                const SizedBox(width: 8),
                FixxerRequestTypeChip(
                  label: 'Open for All',
                  isSelected: selectedTab == FixxerRequestTypeTab.open,
                  onTap: () {
                    setState(() => selectedTab = FixxerRequestTypeTab.open);
                    applyFilters();
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          /// LIST
          Expanded(
            child: filteredRequests.isEmpty
                ? const Center(child: Text('No jobs found'))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: filteredRequests.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, index) {
                      if (index == filteredRequests.length) {
                        // Add extra space at the bottom
                        return const SizedBox(
                          height: kBottomNavigationBarHeight + 20,
                        );
                      }
                      return FixxerJobRequestCard(
                        job: filteredRequests[index],
                        onTap: () {
                          Get.to(() => FixxerJobDetailScreen());
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// =======================
  /// DUMMY DATA
  /// =======================
  List<FixxerJobRequestModel> _dummyRequests() {
    return List.generate(8, (index) {
      return FixxerJobRequestModel(
        clientName: 'Client $index',
        serviceTitle: index.isEven ? 'House Cleaning' : 'Electrician',
        description:
            'Client needs a professional service provider with tools and experience. Needs a professional service provider with tools and experience.',
        type: index.isEven
            ? FixxerJobRequestType.direct
            : FixxerJobRequestType.open,
        minBudget: 20,
        maxBudget: 150 + index * 20,
        location: 'Model Town Bahawalpur',
        dateTime: DateTime.now().add(Duration(days: index)),
        images: List.generate(5, (_) => 'assets/images/profile-banner.jpg'),
        status: index.isEven ? 'booked' : 'pending',
        isFavourite: false,
      );
    });
  }
}
