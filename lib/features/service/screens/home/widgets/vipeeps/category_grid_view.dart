import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:servicex_client_app/common/widgets/others/single_category.dart';
import 'package:servicex_client_app/common/widgets/shimmers/category_shimmer.dart';
import 'package:servicex_client_app/features/service/screens/home/linked_screens/subcategories_screen.dart';

class CategoryGrid extends StatelessWidget {
  final List<Map<String, String>> categories;
  final bool isLoading;

  const CategoryGrid({
    super.key,
    required this.categories,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.zero,
      itemCount: categories.length,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 20,
        crossAxisSpacing: 10,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (_, index) {
        if (isLoading) return const CategoryShimmer();

        final item = categories[index];

        return XSingleCategory(
          title: item["title"]!,
          icon: item["img"]!,
          onTap: () {
            Get.to(() => SubcategoriesScreen());
          },
        );
      },
    );
  }
}
