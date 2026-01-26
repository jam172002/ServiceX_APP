import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

class MapViewContainer extends StatelessWidget {
  final double height;
  final double width;

  const MapViewContainer({
    super.key,
    this.height = 150,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: XColors.borderColor),
      ),
      child: Stack(
        children: [
          Center(child: Icon(Iconsax.map_1, size: 40, color: XColors.grey)),
        ],
      ),
    );
  }
}
