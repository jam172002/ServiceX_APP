import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:iconsax/iconsax.dart';
import 'package:servicex_client_app/features/service/screens/profile/fixxer/fixxer_earnings_screen.dart';
import 'package:servicex_client_app/features/service/screens/profile/fixxer/fixxer_edit_profile_screen.dart';
import 'package:servicex_client_app/features/service/screens/profile/fixxer/fixxer_favourite_screen.dart';
import 'package:servicex_client_app/features/service/screens/profile/fixxer/fixxer_payment_cards_screen.dart';
import 'package:servicex_client_app/features/service/screens/profile/fixxer/fixxer_plans_screen.dart';
import 'package:servicex_client_app/features/service/screens/profile/fixxer/fixxer_reviews_screen.dart';
import 'package:servicex_client_app/features/service/screens/profile/fixxer/fixxer_settings_screen.dart';
import 'package:servicex_client_app/features/service/screens/profile/fixxer/fixxer_wallet_screen.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

class FixxerProfileScreen extends StatelessWidget {
  const FixxerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            /// ---------------- SAME HEADER ----------------
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        const CircleAvatar(
                          radius: 32,
                          backgroundImage: AssetImage(
                            'assets/images/profile.png',
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              Get.to(() => FixxerEditProfileScreen());
                            },
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
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
                          Row(
                            children: [
                              //? Name
                              Text(
                                'Muhammad Sufyan',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 4),
                              //? Badge
                              Text(
                                'Top Rated',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            'iammsufyan@gmail.com',
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // Logout
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

            /// ---------------- SCROLLABLE CONTENT ----------------
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  /// ---------------- STATUS GRID ----------------
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
                            childAspectRatio: 2.4,
                          ),
                      children: const [
                        _StatCard(
                          title: 'Upcoming',
                          count: '4',
                          icon: Iconsax.calendar,
                          bgColor: Colors.blueAccent,
                        ),
                        _StatCard(
                          title: 'Active',
                          count: '2',
                          icon: Iconsax.activity,
                          bgColor: Colors.amber,
                        ),
                        _StatCard(
                          title: 'Completed',
                          count: '18',
                          icon: Iconsax.tick_circle,
                          bgColor: Colors.green,
                        ),
                        _StatCard(
                          title: 'Cancelled',
                          count: '1',
                          icon: Iconsax.close_circle,
                          bgColor: Colors.red,
                        ),
                      ],
                    ),
                  ),

                  /// ---------------- ACTION TILES ----------------
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
                          icon: Iconsax.heart,
                          title: 'Favourites',
                          onTap: () {
                            Get.to(() => FixxerFavouriteScreen());
                          },
                        ),
                        _ActionTile(
                          icon: Iconsax.star,
                          title: 'Reviews and Reputation',
                          onTap: () {
                            Get.to(() => FixxerReviewsScreen());
                          },
                        ),
                        _ActionTile(
                          icon: Iconsax.card,
                          title: 'Payment Cards',
                          onTap: () {
                            Get.to(() => FixxerPaymentCardsScreen());
                          },
                        ),
                        _ActionTile(
                          icon: Iconsax.money,
                          title: 'Earnings',
                          onTap: () {
                            Get.to(() => FixxerEarningsScreen());
                          },
                        ),
                        _ActionTile(
                          icon: Iconsax.wallet,
                          title: 'Wallet',
                          onTap: () {
                            Get.to(() => FixxerWalletScreen());
                          },
                        ),
                        _ActionTile(
                          icon: Iconsax.box,
                          title: 'Packages',
                          onTap: () {
                            Get.to(() => FixxerPlansScreen());
                          },
                        ),
                        _ActionTile(
                          icon: Iconsax.setting_2,
                          title: 'Settings',
                          onTap: () {
                            Get.to(() => FixxerSettingsScreen());
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

/// ---------------- STAT CARD (MATCHED) ----------------
class _StatCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;
  final Color bgColor;

  const _StatCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: bgColor, size: 20),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                count,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: bgColor,
                ),
              ),
              Text(
                title,
                style: const TextStyle(fontSize: 11, color: Colors.black87),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// ---------------- ACTION TILE (SAME AS ORIGINAL) ----------------
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
            const Icon(Iconsax.arrow_right_3, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
