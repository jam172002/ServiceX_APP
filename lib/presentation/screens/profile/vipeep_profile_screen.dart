import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:servicex_client_app/presentation/widgets/favourite_service_provider.dart';
import 'package:servicex_client_app/presentation/widgets/simple_heading.dart';
import 'package:servicex_client_app/presentation/screens/home/create_service_job_screen.dart';
import 'package:servicex_client_app/presentation/screens/home/service_provider_profile_screen.dart';
import 'package:servicex_client_app/presentation/screens/profile/all_favourites_screen.dart';
import 'package:servicex_client_app/presentation/screens/profile/payment_cards_screen.dart';
import 'package:servicex_client_app/presentation/screens/profile/saved_locations_screen.dart';
import 'package:servicex_client_app/presentation/screens/profile/settings_screen.dart';
import 'package:servicex_client_app/presentation/screens/profile/user_profile_edit_screen.dart';
import 'package:servicex_client_app/presentation/screens/profile/wallet_screen.dart';
import 'package:servicex_client_app/presentation/widgets/profile_statcard.dart';
import 'package:servicex_client_app/presentation/widgets/profile_booking_card.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';
import 'package:servicex_client_app/utils/constants/images.dart';

import '../../controllers/auth_controller.dart';



class VipeepProfileScreen extends StatelessWidget {
  const VipeepProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample provider for favourites
    final Map<String, dynamic> provider = {
      "name": "M Sufyan",
      "location": "Bahawalpur",
      "rating": 4.7,
      "image": XImages.serviceProvider,
      "onTap": () => Get.to(() => ServiceProviderProfileScreen()),
      "onBook": () =>
          Get.to(() => CreateServiceJobScreen(showServiceProviderCard: true)),
    };

    final List<Map<String, dynamic>> providers = List.generate(
      10,
      (_) => provider,
    );

    // Sample previous bookings/projects
    final List<Map<String, dynamic>> bookings = List.generate(
      10,
      (index) => {
        "spName": "Service Provider ${index + 1}",
        "spType": "Plumbing",
        "time": "10:00 AM",
        "status": index % 3 == 0
            ? "completed"
            : index % 3 == 1
            ? "pending"
            : "inprogress",
        "desc": "Fixing kitchen sink and water pipeline issue",
        "price": 50 + index * 5,
        "distance": "${index + 1} km",
        "location": "Bahawalpur",
      },
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ---------------- STICKY HEADER ----------------
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),

                child: Row(
                  children: [
                    Stack(
                      children: [
                        const CircleAvatar(
                          radius: 32,
                          backgroundImage: AssetImage(
                            XImages.serviceProvider02,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () => Get.to(() => UserProfileEditScreen()),
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: const BoxDecoration(
                                color: XColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Iconsax.edit,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Muhammad Sufyan',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'iammsufyan@gmail.com',
                            style: TextStyle(fontSize: 11, color: XColors.grey),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Get.find<AuthController>().logout();
                      },
                      icon: const Icon(
                        Iconsax.logout,
                        color: Colors.redAccent,
                        size: 20,
                      ),
                    ),

                  ],
                ),
              ),
            ),

            // ---------------- SCROLLABLE CONTENT ----------------
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  // ---------------- STATS ----------------
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: GridView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: 3.1,
                          ),
                      children: const [
                        VipeepProfileStatCard(
                          title: "New",
                          count: "12",
                          icon: Iconsax.add_circle,
                          bgColor: Colors.blueAccent,
                        ),
                        VipeepProfileStatCard(
                          title: "Active",
                          count: "6",
                          icon: Iconsax.activity,
                          bgColor: Colors.amber,
                        ),
                        VipeepProfileStatCard(
                          title: "Completed",
                          count: "16",
                          icon: Iconsax.tick_circle,
                          bgColor: Colors.green,
                        ),
                        VipeepProfileStatCard(
                          title: "Cancelled",
                          count: "3",
                          icon: Iconsax.close_circle,
                          bgColor: Colors.red,
                        ),
                      ],
                    ),
                  ),

                  // Favourites
                  if (providers.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          XHeading(
                            title: 'Favourites',
                            actionText: 'See All',
                            sidePadding: 16,
                            onActionTap: () =>
                                Get.to(() => AllFavouritesScreen()),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 120,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount: providers.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 12),
                              itemBuilder: (context, index) {
                                final Map<String, dynamic> p = providers[index];
                                return FavouriteServiceProviderAvatar(
                                  name: p['name'] as String,
                                  location: p['location'] as String,
                                  image: p['image'] as String,
                                  rating: p['rating'] as double,
                                  onTap: p['onTap'] as VoidCallback?,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Previous bookings
                  if (bookings.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              "Previous Projects",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 120,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount: bookings.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 12),
                              itemBuilder: (context, index) {
                                return ProfileBookingCard(
                                  data: bookings[index],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Action Tiles
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      0,
                      16,
                      kBottomNavigationBarHeight + 20,
                    ),
                    child: Column(
                      children: [
                        _ActionTile(
                          icon: Iconsax.location,
                          title: "Saved locations",
                          onTap: () {
                            Get.to(() => SavedLocationsScreen());
                          },
                        ),
                        _ActionTile(
                          icon: Iconsax.card,
                          title: "Payment cards",
                          onTap: () {
                            Get.to(() => PaymentCardsScreen());
                          },
                        ),
                        _ActionTile(
                          icon: Iconsax.wallet,
                          title: "Wallet",
                          onTap: () {
                            Get.to(() => WalletScreen());
                          },
                        ),
                        _ActionTile(
                          icon: Iconsax.setting_2,
                          title: "Settings",
                          onTap: () {
                            Get.to(() => SettingsScreen());
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- ACTION TILE ----------------
class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: XColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: XColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Iconsax.arrow_right_3, size: 16, color: XColors.grey),
          ],
        ),
      ),
    );
  }
}
