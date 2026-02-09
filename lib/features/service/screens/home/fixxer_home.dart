import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:servicex_client_app/common/widgets/appbar/custom_home_appbar.dart';
import 'package:servicex_client_app/common/widgets/headings/simple_heading.dart';
import 'package:servicex_client_app/features/service/models/fixxer_job_request_model.dart';
import 'package:servicex_client_app/features/service/screens/home/widgets/fixxers/fixxer_booking_card.dart';
import 'package:servicex_client_app/features/service/screens/home/widgets/fixxers/fixxer_home_booking_card.dart';
import 'package:servicex_client_app/features/service/screens/home/widgets/fixxers/home_connects_card.dart';
import 'package:servicex_client_app/features/service/screens/profile/fixxer/fixxer_edit_profile_screen.dart';
import 'package:servicex_client_app/features/service/screens/profile/fixxer/fixxer_notifications_screen.dart';
import 'package:servicex_client_app/features/service/screens/profile/fixxer/fixxer_plans_screen.dart';
import 'package:servicex_client_app/features/service/screens/profile/fixxer/fixxer_settings_screen.dart';
import 'package:servicex_client_app/features/service/screens/requests/widgets/fixxers/fixxer_job_request_card.dart';
import 'package:servicex_client_app/features/service/screens/home/linked_screens/fixxer_job_detail_screen.dart';
import 'package:servicex_client_app/utils/constants/enums.dart';

class FixxerHomeScreen extends StatelessWidget {
  final Function(int)? onSwitchTab;
  FixxerHomeScreen({super.key, this.onSwitchTab});

  /// HOME DUMMY JOBS
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

  final List<FixxerBookingModel> homeBookings = List.generate(
    6,
    (index) => FixxerBookingModel(
      providerName: 'Provider ${index + 1}',
      serviceTitle: index.isEven ? 'Wiring' : 'House Cleaning',
      description:
          'Professional service for your home with experience and tools.',
      amount: 100 + index * 20,
      dateTime: DateTime.now().add(Duration(days: index)),
      location: 'Model Town, Phase ${index + 1}, Bahawalpur',
      images: [
        'assets/images/service-provider.jpg',
        'assets/images/service-provider2.jpg',
      ],
      isFavourite: index % 2 == 0,
      isCancelled: false,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final homeJobs = _homeJobs();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(95),
        child: CustomHomeAppBar(
          name: "Muhammad Sufyan",
          location: 'Model Town, Bahawalpur',
          country: "Pakistan",
          imagePath: "assets/images/profile.png",
          onSettingTap: () => Get.to(() => FixxerSettingsScreen()),
          onProfileTap: () => Get.to(() => FixxerEditProfileScreen()),
          onNotificationTap: () => Get.to(() => FixxerNotificationsScreen()),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          children: [
            /// CONNECTS CARD
            HomeConnectsCard(
              remainingConnects: 10,
              activePackage: "Starter Plan",
              todaysProjects: 3,
              bookedDates: [
                DateTime.now(),
                DateTime.now().add(const Duration(days: 2)),
              ],
              onAddConnectsTap: () => Get.to(() => FixxerPlansScreen()),
            ),

            const SizedBox(height: 16),

            /// NEW JOBS
            XHeading(
              title: 'New Jobs',
              actionText: 'View All',
              onActionTap: () {
                if (onSwitchTab != null) onSwitchTab!(2);
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
                  onTap: () => Get.to(() => FixxerJobDetailScreen()),
                );
              },
            ),
            const SizedBox(height: 16),

            /// BOOKINGS
            XHeading(
              title: 'Bookings',
              actionText: 'View All',
              onActionTap: () {
                if (onSwitchTab != null) onSwitchTab!(1); // Bookings tab
              },
              sidePadding: 0,
            ),
            const SizedBox(height: 10),

            // Horizontal scrollable bookings
            SizedBox(
              height: 274,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: homeBookings.length,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final booking = homeBookings[index];
                  return FixxerHomeBookingCard(
                    onTap: () {
                      Get.to(() => FixxerJobDetailScreen());
                    },
                    providerName: booking.providerName,
                    serviceTitle: booking.serviceTitle,
                    description: booking.description,
                    amount: booking.amount,
                    dateTime: booking.dateTime,
                    location: booking.location,
                    images: booking.images,
                    isFavourite: booking.isFavourite,
                    isCancelled: booking.isCancelled,
                  );
                },
              ),
            ),

            const SizedBox(height: kBottomNavigationBarHeight + 35),
          ],
        ),
      ),
    );
  }
}
