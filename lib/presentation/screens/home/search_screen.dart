import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:servicex_client_app/presentation/widgets/common_appbar.dart';
import 'package:servicex_client_app/presentation/widgets/search_filter_container.dart';
import 'package:servicex_client_app/presentation/screens/home/service_provider_profile_screen.dart';
import 'package:servicex_client_app/presentation/screens/home/subcategories_screen.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

import '../../controllers/x_search_controller.dart';


class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});


  @override
  Widget build(BuildContext context) {
    final controller = Get.find<XSearchController>();

    Widget buildSectionTitle(String title) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      );
    }

    Widget buildServiceTile(Map<String, dynamic> service) {
      final iconUrl = (service['iconUrl'] ?? '') as String;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: GestureDetector(
          onTap: () => Get.to(
                () => SubcategoriesScreen(
              categoryId: (service['categoryId'] ?? '') as String,
              categoryName: (service['categoryName'] ?? '') as String,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: XColors.lightTint.withValues(alpha: 0.5),
                radius: 25,
                child: SizedBox(
                  height: 22,
                  child: ColorFiltered(
                    colorFilter: const ColorFilter.mode(XColors.primary, BlendMode.srcIn),
                    child: Image.network(
                      iconUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(Icons.category, color: XColors.primary),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(service['name']),
            ],
          ),
        ),
      );
    }

    Widget buildProviderTile(Map<String, dynamic> provider) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: GestureDetector(
          onTap: () => Get.to(() => ServiceProviderProfileScreen()),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: XColors.lightTint.withValues(alpha: 0.5),
                backgroundImage: AssetImage(provider['image']),
              ),
              const SizedBox(width: 12),
              Text(provider['name']),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: XAppBar(title: 'Search'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              // Search field with filter button
              SearchWithFilter(
                horPadding: 0,
                onFilterTap: () {},
                onChanged: (value) {
                  controller.searchQuery.value = value;
                },
              ),

              const SizedBox(height: 12),

              // Results
              Expanded(
                child: Obx(() {
                  if (controller.searchQuery.value.isEmpty) {
                    // No input illustration
                    return Center(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.6,
                        child: Image.asset(
                          'assets/images/search-illustration.png',
                        ),
                      ),
                    );
                  }

                  final services = controller.filteredServices; // ✅ now List<ServiceSubcategory>
                  final providers = controller.filteredProviders; //

                  if (services.isEmpty && providers.isEmpty) {
                    // No results found illustration
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.4,
                            child: Image.asset(
                              'assets/images/no-data-found.png',
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No data Found!',
                            style: TextStyle(color: XColors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView(
                    children: [
                      if (services.isNotEmpty) buildSectionTitle('Services'),
                      ...services.map((s) => buildServiceTile(s as Map<String, dynamic>)),
                      if (services.isNotEmpty && providers.isNotEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Divider(
                            height: 1,
                            thickness: 1,
                            color: XColors.borderColor,
                          ),
                        ),
                      if (providers.isNotEmpty)
                        buildSectionTitle('Service Providers'),
                      ...providers.map((p) => buildProviderTile(p)),
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
