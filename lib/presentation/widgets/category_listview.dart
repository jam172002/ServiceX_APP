import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:servicex_client_app/presentation/widgets/single_category.dart';
import 'package:servicex_client_app/presentation/screens/home/subcategories_screen.dart';

import '../controllers/category_controller.dart';

class CategoryListView extends StatelessWidget {
  const CategoryListView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<CategoryController>(); // ✅ use existing controller

    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: SizedBox(
        height: 85,
        child: Obx(() {
          if (c.isLoading.value) {
            return const Center(
              child: SizedBox(height: 18, width: 18, child: CircularProgressIndicator()),
            );
          }

          if (c.error.value.isNotEmpty) {
            return Center(child: Text('Error: ${c.error.value}'));
          }

          if (c.categories.isEmpty) {
            return const Center(child: Text('No categories yet'));
          }

          return ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: c.categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final item = c.categories[index];

              return XSingleCategory(
                title: item.name,
                icon: item.iconUrl,
                onTap: () {
                  Get.to(() => SubcategoriesScreen(
                    categoryId: item.id,
                    categoryName: item.name,
                  ));
                },
              );
            },
          );
        }),
      ),
    );
  }
}