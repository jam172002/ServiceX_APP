import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:servicex_client_app/common/widgets/appbar/custom_home_appbar.dart';
import 'package:servicex_client_app/common/widgets/bottom_sheets/location_bottom_sheet.dart';
import 'package:servicex_client_app/common/widgets/headings/simple_heading.dart';
import 'package:servicex_client_app/features/service/models/fixxer_job_request_model.dart';
import 'package:servicex_client_app/features/service/screens/home/linked_screens/notifications_screen.dart';
import 'package:servicex_client_app/features/service/screens/home/widgets/fixxers/home_active_plan_card.dart';
import 'package:servicex_client_app/features/service/screens/home/widgets/fixxers/home_connects_card.dart';
import 'package:servicex_client_app/features/service/screens/profile/linked_screens/settings_screen.dart';
import 'package:servicex_client_app/features/service/screens/requests/fixxer_requests_screen.dart';
import 'package:servicex_client_app/features/service/screens/requests/widgets/fixxers/fixxer_job_request_card.dart';
import 'package:servicex_client_app/features/service/screens/home/linked_screens/fixxer_job_detail_screen.dart';
import 'package:servicex_client_app/utils/constants/enums.dart';

class FixxerHomeScreen extends StatelessWidget {
  const FixxerHomeScreen({super.key});

  /// =======================
  /// HOME DUMMY JOBS
  /// =======================
  List<FixxerJobRequestModel> _homeJobs() {
    return List.generate(3, (index) {
      return FixxerJobRequestModel(
        clientName: 'Client $index',
        serviceTitle: index.isEven ? 'House Cleaning' : 'Electrician',
        description:
            'Client needs a professional service provider with tools and experience.',
        type: index == 0
            ? FixxerJobRequestType.direct
            : FixxerJobRequestType.open,
        minBudget: 50,
        maxBudget: 120 + index * 20,
        location: 'Model Town, Bahawalpur',
        dateTime: DateTime.now().add(Duration(days: index)),
        images: List.generate(4, (_) => 'assets/images/profile-banner.jpg'),
        status: index.isEven ? 'booked' : 'pending',
        isFavourite: false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Dummy booked dates
    final List<DateTime> bookedDates = [
      DateTime.now(),
      DateTime.now().add(const Duration(days: 2)),
      DateTime.now().add(const Duration(days: 5)),
    ];

    final homeJobs = _homeJobs();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(95),
        child: CustomHomeAppBar(
          name: "Muhammad Sufyan",
          location: 'Model Town, Bahawalpur',
          country: "Pakistan",
          imagePath: "assets/images/profile.png",
          onLocationTap: () => showLocationBottomSheet(context),
          onSettingTap: () => Get.to(() => SettingsScreen()),
          onNotificationTap: () => Get.to(() => NotificationsScreen()),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          children: [
            /// =======================
            /// CONNECTS CARD
            /// =======================
            HomeConnectsCard(
              remainingConnects: 10,
              activePackage: "Starter Plan",
              todaysProjects: 3,
              bookedDates: bookedDates,
            ),

            const SizedBox(height: 16),

            /// =======================
            /// NEW JOBS
            /// =======================
            XHeading(
              title: 'New Jobs',
              actionText: 'View All',
              onActionTap: () {
                () => FixxerRequestScreen();
              },
              sidePadding: 0,
            ),

            const SizedBox(height: 10),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: homeJobs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return FixxerJobRequestCard(
                  job: homeJobs[index],
                  onTap: () {
                    Get.to(() => FixxerJobDetailScreen());
                  },
                );
              },
            ),

            const SizedBox(height: 16),

            /// =======================
            /// ACTIVE PLAN
            /// =======================
            XHeading(
              title: 'Active Plan',
              actionText: 'All Plans',
              onActionTap: () {},
              sidePadding: 0,
            ),

            const SizedBox(height: 10),

            const HomeActivePlanCard(),

            /// Bottom spacing
            const SizedBox(height: kBottomNavigationBarHeight + 35),
          ],
        ),
      ),
    );
  }
}
