import 'dart:ui';
import 'package:custom_navigation_bar/custom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:servicex_client_app/features/service/screens/bookings/fixxer_booking_screen.dart';
import 'package:servicex_client_app/features/service/screens/home/fixxer_home.dart';
import 'package:servicex_client_app/features/service/screens/inbox/fixxer_allchat_screen.dart';
import 'package:servicex_client_app/features/service/screens/profile/fixxer_profile_screen.dart';
import 'package:servicex_client_app/features/service/screens/requests/fixxer_requests_screen.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

class FixxerNavigation extends StatefulWidget {
  const FixxerNavigation({super.key});

  @override
  State<FixxerNavigation> createState() => _FixxerNavigationState();
}

class _FixxerNavigationState extends State<FixxerNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    FixxerHomeScreen(),
    FixxerBookingScreen(),
    FixxerRequestScreen(),
    FixxerAllChatScreen(),
    FixxerProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            /// Current screen
            _screens[_selectedIndex],

            /// Floating blurred navigation
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    color: XColors.borderColor.withValues(alpha: 0.3),
                    child: CustomNavigationBar(
                      isFloating: true,
                      elevation: 0,
                      iconSize: 25,
                      borderRadius: const Radius.circular(24),
                      selectedColor: XColors.primary,
                      unSelectedColor: XColors.grey,
                      backgroundColor: Colors.transparent,
                      strokeColor: XColors.lighterTint,
                      currentIndex: _selectedIndex,
                      onTap: (index) {
                        setState(() => _selectedIndex = index);
                      },
                      items: [
                        CustomNavigationBarItem(
                          icon: const Icon(Iconsax.home_2),
                        ),
                        CustomNavigationBarItem(
                          icon: const Icon(Iconsax.calendar_2),
                        ),
                        CustomNavigationBarItem(
                          icon: const Icon(Iconsax.direct),
                        ),
                        CustomNavigationBarItem(
                          icon: const Icon(Iconsax.message),
                        ),
                        CustomNavigationBarItem(icon: const Icon(Iconsax.user)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
