import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:servicex_client_app/domain/models/service_subcategory.dart';
import 'package:servicex_client_app/presentation/screens/categories_n_subcategories/controller/subcategories_controller.dart';
import 'package:servicex_client_app/presentation/screens/categories_n_subcategories/subcatagory_service_providers_screen.dart';
import 'package:servicex_client_app/presentation/widgets/common_appbar.dart';
import 'package:servicex_client_app/presentation/widgets/search_filter_container.dart';
import 'package:servicex_client_app/presentation/widgets/single_subcatagory.dart';

import '../service_provider_profile/service_provider_profile_screen.dart';

class SubcategoriesScreen extends StatelessWidget {
  final String categoryId;
  final String categoryName;

  const SubcategoriesScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      SubcategoriesController(categoryId: categoryId),
      tag: categoryId,
    );

    return Scaffold(
      appBar: XAppBar(title: categoryName),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            const SearchWithFilter(horPadding: 16),
            const SizedBox(height: 20),

            Expanded(
              child: Obx(() {
                // ── Loading ──────────────────────────────────────
                if (controller.subsLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                // ── Error ────────────────────────────────────────
                if (controller.subsError.value.isNotEmpty) {
                  return Center(
                    child: Text(
                      controller.subsError.value,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                // ── Empty ────────────────────────────────────────
                if (controller.subcategories.isEmpty) {
                  return const Center(
                    child: Text(
                      'No subcategories found.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                // ── List ─────────────────────────────────────────
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      ...controller.subcategories.map(
                            (sub) => Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: _SubcategorySection(
                            sub: sub,
                            controller: controller,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// One subcategory section — loads its own fixxers on first render
// ─────────────────────────────────────────────────────────────────
class _SubcategorySection extends StatefulWidget {
  final ServiceSubcategory sub;
  final SubcategoriesController controller;

  const _SubcategorySection({
    required this.sub,
    required this.controller,
  });

  @override
  State<_SubcategorySection> createState() => _SubcategorySectionState();
}

class _SubcategorySectionState extends State<_SubcategorySection> {
  // Each section manages its own fixxers stream independently
  final RxList<Map<String, dynamic>> _providers = <Map<String, dynamic>>[].obs;
  final RxBool _loading = true.obs;

  @override
  void initState() {
    super.initState();
    _fetchFixxers();
  }

  void _fetchFixxers() {
    widget.controller.loadFixxersForSubcategory(widget.sub);

    // Watch the shared fixxers list and filter for this subcategory
    ever(widget.controller.fixxers, (_) => _syncProviders());
    ever(widget.controller.fixxersLoading, (_) => _syncProviders());
    _syncProviders();
  }

  void _syncProviders() {
    if (widget.controller.selectedSubcategory.value?.id == widget.sub.id) {
      _providers.assignAll(
        widget.controller.fixxers.map((f) => _toProviderMap(f)).toList(),
      );
      _loading.value = widget.controller.fixxersLoading.value;
    }
  }

  Map<String, dynamic> _toProviderMap(fixer) => {
    'name': fixer.fullName,
    'location': fixer.address,
    'rating': 4.5,
    'imageUrl': fixer.profileImageUrl,
    'onTap': () => Get.to(
          () => ServiceProviderProfileScreen(),
      arguments: fixer,
    ),
    'onInvite': () => debugPrint('Invited: ${fixer.fullName}'),
  };

  @override
  Widget build(BuildContext context) {
    return Obx(() => SingleSubCategory(
      title: widget.sub.name,
      actionText: 'See all',
      onActionTap: () => Get.to(
            () => CatagoryServiceProviderScreen(
          screenTitle: widget.sub.name,
          subcategoryId: widget.sub.id,
        ),
      ),
      providers: _providers.toList(),
      isLoading: _loading.value,
    ));
  }
}