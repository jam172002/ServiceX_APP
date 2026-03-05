import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:servicex_client_app/presentation/widgets/common_appbar.dart';
import 'package:servicex_client_app/presentation/widgets/category_grid_view.dart';
import '../../controllers/category_controller.dart';

class AllCatagoriesScreen extends StatelessWidget {
  const AllCatagoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CategoryController(), permanent: true);

    return Scaffold(
      appBar: XAppBar(title: 'Categories'),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.error.value.isNotEmpty) {
            return Center(child: Text(controller.error.value));
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: CategoryGrid(
              categories: controller.categories, // ✅ pass model list
              isLoading: false,
            ),
          );
        }),
      ),
    );
  }
}