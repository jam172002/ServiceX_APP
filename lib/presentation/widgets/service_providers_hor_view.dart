import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:servicex_client_app/presentation/screens/home/bottom_tabs/controller/home_tab_controller.dart';
import 'package:servicex_client_app/presentation/screens/service_provider_profile/service_provider_profile_screen.dart';
import 'package:servicex_client_app/presentation/widgets/service_provider_ver_card.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';
import 'package:servicex_client_app/utils/constants/images.dart';

import '../../domain/models/fixer_model.dart';

class ServiceProviderHorizontalList extends StatelessWidget {
  final double height;

  const ServiceProviderHorizontalList({
    super.key,
    this.height = 235,
  });

  @override
  Widget build(BuildContext context) {
    final HomeController home = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>()
        : Get.put(HomeController());

    return Obx(() {
      // ── Loading ──────────────────────────────────────────────────
      if (home.isLoadingNearby.value) {
        return Padding(
          padding: const EdgeInsets.only(left: 16),
          child: SizedBox(
            height: height,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (_, __) => Container(
                width: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade200,
                ),
              ),
            ),
          ),
        );
      }

      // ── Empty ────────────────────────────────────────────────────
      if (home.nearbyFixxers.isEmpty) {
        return const SizedBox(
          height: 80,
          child: Center(
            child: Text(
              'No fixxers found within 20 km',
              style: TextStyle(color: XColors.grey, fontSize: 13),
            ),
          ),
        );
      }

      // ── List ─────────────────────────────────────────────────────
      final fixxers = home.nearbyFixxers.length > 8
          ? home.nearbyFixxers.sublist(0, 8)
          : home.nearbyFixxers;

      return Padding(
        padding: const EdgeInsets.only(left: 16),
        child: SizedBox(
          height: height,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: fixxers.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (_, i) {
              final FixerModel fixxer = fixxers[i];
              return ServiceProviderVerCard(
                name: fixxer.fullName,
                location: fixxer.location.address.isNotEmpty
                    ? fixxer.location.address.split(',').first
                    : 'Location not set',
                rating: fixxer.rating,
                imageUrl: fixxer.profileImageUrl,
                image: XImages.serviceProvider, // asset fallback
                onTap: () => Get.to(
                      () => ServiceProviderProfileScreen(),
                  arguments: fixxer,
                ),
                onBook: () => Get.to(
                      () => ServiceProviderProfileScreen(),
                  arguments: fixxer,
                ),
              );
            },
          ),
        ),
      );
    });
  }
}