import 'package:flutter/material.dart';
import 'package:servicex_client_app/presentation/widgets/common_appbar.dart';
import 'package:servicex_client_app/presentation/widgets/category_grid_view.dart';

class AllCatagoriesScreen extends StatelessWidget {
  const AllCatagoriesScreen({super.key});

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
      {'title': "AC Repair", 'img': 'assets/icons/ac.png'},
      {'title': "Plumber", 'img': 'assets/icons/plumber.png'},
      {'title': "Car Wash", 'img': 'assets/icons/carwash.png'},
      {'title': "Painter", 'img': 'assets/icons/paint.png'},
      {'title': "Gardener", 'img': 'assets/icons/garden.png'},
      {'title': "Cleaning", 'img': 'assets/icons/cleaning.png'},
      {'title': "Mechanic", 'img': 'assets/icons/mechanic.png'},
      {'title': "AC Repair", 'img': 'assets/icons/ac.png'},
      {'title': "Painter", 'img': 'assets/icons/paint.png'},
      {'title': "Gardener", 'img': 'assets/icons/garden.png'},
      {'title': "Cleaning", 'img': 'assets/icons/cleaning.png'},
      {'title': "Mechanic", 'img': 'assets/icons/mechanic.png'},
      {'title': "AC Repair", 'img': 'assets/icons/ac.png'},
      {'title': "Plumber", 'img': 'assets/icons/plumber.png'},
      {'title': "Car Wash", 'img': 'assets/icons/carwash.png'},
      {'title': "Painter", 'img': 'assets/icons/paint.png'},
      {'title': "Gardener", 'img': 'assets/icons/garden.png'},
      {'title': "Cleaning", 'img': 'assets/icons/cleaning.png'},
      {'title': "Mechanic", 'img': 'assets/icons/mechanic.png'},
      {'title': "AC Repair", 'img': 'assets/icons/ac.png'},
      {'title': "Plumber", 'img': 'assets/icons/plumber.png'},
      {'title': "Car Wash", 'img': 'assets/icons/carwash.png'},
      {'title': "Painter", 'img': 'assets/icons/paint.png'},
      {'title': "Gardener", 'img': 'assets/icons/garden.png'},
      {'title': "Cleaning", 'img': 'assets/icons/cleaning.png'},
      {'title': "Mechanic", 'img': 'assets/icons/mechanic.png'},
    ];

    return Scaffold(
      appBar: XAppBar(title: 'Categories'),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.all(16.0),
          child: CategoryGrid(categories: items, isLoading: false),
        ),
      ),
    );
  }
}
