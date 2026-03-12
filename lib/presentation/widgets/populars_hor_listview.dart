import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:servicex_client_app/domain/models/service_subcategory.dart';
import 'package:servicex_client_app/presentation/screens/categories_n_subcategories/controller/category_controller.dart';
import 'package:servicex_client_app/presentation/screens/categories_n_subcategories/subcatagory_service_providers_screen.dart';
import 'package:servicex_client_app/presentation/screens/home/bottom_tabs/controller/home_tab_controller.dart';
import 'package:servicex_client_app/presentation/widgets/popular_home_item_card.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';
import 'package:servicex_client_app/utils/constants/images.dart';

class PopularHomeHorizontalList extends StatelessWidget {
  const PopularHomeHorizontalList({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController home = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>()
        : Get.put(HomeController());

    final CategoryController catCtrl = Get.find<CategoryController>();

    return Obx(() {
      // ── Loading ──────────────────────────────────────────────────
      if (home.isLoadingPopular.value) {
        return SizedBox(
          height: 250,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            padding: const EdgeInsets.only(left: 16),
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (_, __) => _ShimmerCard(),
          ),
        );
      }

      // ── Empty ────────────────────────────────────────────────────
      if (home.popularSubcategories.isEmpty) {
        return const SizedBox(
          height: 80,
          child: Center(
            child: Text(
              'No popular services yet',
              style: TextStyle(color: XColors.grey, fontSize: 13),
            ),
          ),
        );
      }

      // ── List ─────────────────────────────────────────────────────
      return SizedBox(
        height: 250,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: home.popularSubcategories.length,
          padding: const EdgeInsets.only(left: 16),
          separatorBuilder: (_, __) => const SizedBox(width: 16),
          itemBuilder: (_, i) {
            final ServiceSubcategory sub = home.popularSubcategories[i];

            // Resolve parent category ID to display name for the badge
            final String catName = catCtrl.categoryName(sub.categoryId);

            return PopularHomeCard(
              title: sub.name,        // e.g. "AC Repair"
              mainCategory: catName,  // e.g. "Electric"
              description: 'Professional ${sub.name} service.',
              price: 'Contact for price',
              imagePath: XImages.serviceProviderBanner,
              imageUrl: sub.imageUrl.isNotEmpty ? sub.imageUrl : null,
              onTap: () => Get.to(
                    () => CatagoryServiceProviderScreen(
                  screenTitle: sub.name,
                  subcategoryId: sub.id,
                ),
              ),
            );
          },
        ),
      );
    });
  }
}

// ── Shimmer placeholder ──────────────────────────────────────────

class _ShimmerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade200,
      ),
    );
  }
}