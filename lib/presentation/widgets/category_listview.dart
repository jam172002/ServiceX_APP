import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:servicex_client_app/presentation/widgets/single_category.dart';
import 'package:servicex_client_app/presentation/screens/home/subcategories_screen.dart';

class CategoryListView extends StatelessWidget {
  const CategoryListView({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      {'title': "Electric", 'img': 'assets/icons/flash.png'},
      {'title': "AC Repair", 'img': 'assets/icons/ac.png'},
      {'title': "Plumber", 'img': 'assets/icons/plumber.png'},
      {'title': "Car Wash", 'img': 'assets/icons/carwash.png'},
      {'title': "Painter", 'img': 'assets/icons/paint.png'},
      {'title': "Gardener", 'img': 'assets/icons/garden.png'},
      {'title': "Cleaning", 'img': 'assets/icons/cleaning.png'},
      {'title': "Mechanic", 'img': 'assets/icons/mechanic.png'},
    ];

    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: SizedBox(
        height: 85,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: 8,
          separatorBuilder: (_, __) => const SizedBox(width: 16),
          itemBuilder: (context, index) {
            final item = items[index];
            return XSingleCategory(
              title: item['title']!,
              icon: item['img']!,
              onTap: () {
                Get.to(() => SubcategoriesScreen());
              },
            );
          },
        ),
      ),
    );
  }
}
