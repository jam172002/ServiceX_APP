import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:servicex_client_app/domain/models/service_category.dart';
import 'package:servicex_client_app/domain/models/service_subcategory.dart';
import 'package:servicex_client_app/presentation/screens/categories_n_subcategories/all_subcategories_screen.dart';
import 'package:servicex_client_app/presentation/screens/service_provider_profile/service_provider_profile_screen.dart';
import 'package:servicex_client_app/presentation/widgets/common_appbar.dart';
import 'package:servicex_client_app/presentation/widgets/search_filter_container.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

import '../../../domain/models/fixxer_model.dart';
import '../categories_n_subcategories/subcatagory_service_providers_screen.dart';
import 'x_search_controller.dart';
import 'search_filter_sheet.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<XSearchController>();

    return Scaffold(
      appBar: XAppBar(title: 'Search'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              // ── Search bar ──────────────────────────────────────────────
              Obx(() {
                final hasFilters = controller.activeFilters.value.isActive;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    SearchWithFilter(
                      horPadding: 0,
                      onFilterTap: () => SearchFilterSheet.show(context),
                      onChanged: (v) => controller.searchQuery.value = v,
                    ),
                    // Active filter badge
                    if (hasFilters)
                      Positioned(
                        top: -4,
                        right: -4,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                );
              }),

              const SizedBox(height: 8),

              // ── Active filter chips row ─────────────────────────────────
              Obx(() {
                final f = controller.activeFilters.value;
                if (!f.isActive) return const SizedBox.shrink();
                return SizedBox(
                  height: 32,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      if (f.categoryId != null)
                        _FilterBadge(
                          label: controller.categoryById(f.categoryId!)?.name ?? 'Category',
                          onRemove: () => controller.applyFilters(
                            f.copyWith(clearCategory: true),
                          ),
                        ),
                      if (f.gender != null)
                        _FilterBadge(
                          label: f.gender!,
                          onRemove: () => controller.applyFilters(
                            f.copyWith(clearGender: true),
                          ),
                        ),
                      if (f.minRating != null)
                        _FilterBadge(
                          label: '${f.minRating!.toInt()}+ ★',
                          onRemove: () => controller.applyFilters(
                            f.copyWith(clearMinRating: true),
                          ),
                        ),
                      if (f.minRate != null || f.maxRate != null)
                        _FilterBadge(
                          label:
                          'PKR ${(f.minRate ?? 0).toInt()}–${(f.maxRate ?? 500).toInt()}${(f.maxRate ?? 500) >= 500 ? '+' : ''}',
                          onRemove: () => controller.applyFilters(SearchFilters(
                            minRating: f.minRating,
                            gender: f.gender,
                            categoryId: f.categoryId,
                            availableDays: f.availableDays,
                          )),
                        ),
                      if (f.availableDays.isNotEmpty)
                        _FilterBadge(
                          label: f.availableDays.length == 1
                              ? f.availableDays.first
                              : '${f.availableDays.length} days',
                          onRemove: () => controller.applyFilters(
                            f.copyWith(availableDays: []),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: GestureDetector(
                          onTap: controller.clearFilters,
                          child: Text(
                            'Clear all',
                            style: TextStyle(
                              color: Colors.red.shade400,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 8),

              // ── Results ─────────────────────────────────────────────────
              Expanded(
                child: Obx(() {
                  final query = controller.searchQuery.value.trim();
                  final hasFilters = controller.activeFilters.value.isActive;

                  if (query.isEmpty && !hasFilters) {
                    return Center(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.6,
                        child: Image.asset('assets/images/search-illustration.png'),
                      ),
                    );
                  }

                  final categories = controller.filteredCategories;
                  final services = controller.filteredServices;
                  final fixxers = controller.filteredFixxers;

                  final isEmpty =
                      categories.isEmpty && services.isEmpty && fixxers.isEmpty;

                  if (isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.4,
                            child: Image.asset('assets/images/no-data-found.png'),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No results found!',
                            style: TextStyle(color: XColors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView(
                    children: [
                      // Categories
                      if (categories.isNotEmpty) ...[
                        _SectionTitle(title: 'Categories'),
                        ...categories.map((c) => _CategoryTile(category: c)),
                        const SizedBox(height: 8),
                      ],

                      // Services (subcategories)
                      if (services.isNotEmpty) ...[
                        if (categories.isNotEmpty)
                          const Divider(height: 1, color: XColors.borderColor),
                        _SectionTitle(title: 'Services'),
                        ...services.map((s) => _ServiceTile(
                          sub: s,
                          categoryName:
                          controller.categoryById(s.categoryId)?.name ?? '',
                        )),
                        const SizedBox(height: 8),
                      ],

                      // Fixxers
                      if (fixxers.isNotEmpty) ...[
                        if (categories.isNotEmpty || services.isNotEmpty)
                          const Divider(height: 1, color: XColors.borderColor),
                        _SectionTitle(
                          title: 'Fixxers',
                          count: fixxers.length,
                        ),
                        ...fixxers.map((f) => _FixxerTile(fixxer: f)),
                      ],
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Section title ────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  final int? count;
  const _SectionTitle({required this.title, this.count});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        if (count != null) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: XColors.lightTint.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 11,
                color: XColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    ),
  );
}

// ── Category tile ─────────────────────────────────────────────────────────────

class _CategoryTile extends StatelessWidget {
  final ServiceCategory category;
  const _CategoryTile({required this.category});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: GestureDetector(
      onTap: () => Get.to(() => SubcategoriesScreen(
        categoryId: category.id,
        categoryName: category.name,
      )),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: XColors.lightTint.withValues(alpha: 0.5),
            radius: 22,
            child: SizedBox(
              height: 20,
              child: ColorFiltered(
                colorFilter: const ColorFilter.mode(
                    XColors.primary, BlendMode.srcIn),
                child: Image.network(
                  category.iconUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) =>
                  const Icon(Icons.category, color: XColors.primary, size: 18),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              category.name,
              style: const TextStyle(
                fontSize: 14,
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

// ── Service (subcategory) tile ────────────────────────────────────────────────

class _ServiceTile extends StatelessWidget {
  final ServiceSubcategory sub;
  final String categoryName;
  const _ServiceTile({required this.sub, required this.categoryName});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: GestureDetector(
      onTap: () => Get.to(() => CatagoryServiceProviderScreen(
        screenTitle: sub.name,
        subcategoryId: sub.id,
      )),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: XColors.lightTint.withValues(alpha: 0.5),
            ),
            clipBehavior: Clip.hardEdge,
            child: sub.imageUrl.isNotEmpty
                ? CachedNetworkImage(
              imageUrl: sub.imageUrl,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) =>
              const Icon(Icons.build, color: XColors.primary, size: 20),
            )
                : const Icon(Icons.build, color: XColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sub.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (categoryName.isNotEmpty)
                  Text(
                    categoryName,
                    style: const TextStyle(
                      fontSize: 11,
                      color: XColors.grey,
                    ),
                  ),
              ],
            ),
          ),
          const Icon(Iconsax.arrow_right_3, size: 16, color: XColors.grey),
        ],
      ),
    ),
  );
}

// ── Fixxer tile ───────────────────────────────────────────────────────────────

class _FixxerTile extends StatelessWidget {
  final FixxerUser fixxer;
  const _FixxerTile({required this.fixxer});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: GestureDetector(
      onTap: () => Get.to(
            () => ServiceProviderProfileScreen(),
        arguments: fixxer,
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: XColors.lightTint.withValues(alpha: 0.5),
            child: fixxer.profileImageUrl != null &&
                fixxer.profileImageUrl!.isNotEmpty
                ? ClipOval(
              child: CachedNetworkImage(
                imageUrl: fixxer.profileImageUrl!,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => const Icon(
                  Icons.person,
                  color: XColors.primary,
                ),
              ),
            )
                : const Icon(Icons.person, color: XColors.primary),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fixxer.fullName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  fixxer.location.address.isNotEmpty
                      ? fixxer.location.address
                      : 'Location not set',
                  style: const TextStyle(fontSize: 11, color: XColors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Rate + rating
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  const Icon(Iconsax.star5, color: XColors.warning, size: 13),
                  const SizedBox(width: 2),
                  Text(
                    fixxer.rating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (fixxer.hourlyRate != null)
                Text(
                  'PKR ${fixxer.hourlyRate!.toInt()}/hr',
                  style: const TextStyle(
                    fontSize: 11,
                    color: XColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ],
      ),
    ),
  );
}

// ── Active filter badge chip ──────────────────────────────────────────────────

class _FilterBadge extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;
  const _FilterBadge({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 6),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: XColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: XColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: XColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, size: 13, color: XColors.primary),
          ),
        ],
      ),
    ),
  );
}