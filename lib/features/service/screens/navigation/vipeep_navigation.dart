import 'dart:ui';
import 'package:custom_navigation_bar/custom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:servicex_client_app/features/service/screens/bookings/vipeep_booking_screen.dart';
import 'package:servicex_client_app/features/service/screens/home/vipeep_home.dart';
import 'package:servicex_client_app/features/service/screens/inbox/vipeep_allchat_screen.dart';
import 'package:servicex_client_app/features/service/screens/profile/vipeep/vipeep_profile_screen.dart';
import 'package:servicex_client_app/features/service/screens/requests/vipeep_request_screen.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

class VipeepNavigation extends StatefulWidget {
  const VipeepNavigation({super.key});

  @override
  State<VipeepNavigation> createState() => _VipeepNavigationState();
}

class _VipeepNavigationState extends State<VipeepNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    VipeepHomeScreen(),
    VipeepBookingScreen(),
    VipeepRequestScreen(),
    VipeepAllChatScreen(),
    VipeepProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            _screens[_selectedIndex],

            // Floating bottom nav
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
                      onTap: (i) => setState(() => _selectedIndex = i),
                      currentIndex: _selectedIndex,
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
