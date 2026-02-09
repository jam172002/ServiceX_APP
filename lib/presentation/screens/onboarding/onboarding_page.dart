import 'package:flutter/material.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';
import 'package:servicex_client_app/utils/constants/sizes.dart';
import 'package:servicex_client_app/utils/helpers/helper_functions.dart';

class OnBoardingPage extends StatelessWidget {
  const OnBoardingPage({
    super.key,
    required this.image,
    required this.title,
    required this.subtitle,
  });
  final String image, title, subtitle;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(XSizes.defaultSpace),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Image(
              width: XHelperFunctions.screenWidth() * 0.8,
              height: XHelperFunctions.screenHeight() * 0.6,
              image: AssetImage(image),
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: XColors.black,
            ),
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: TextStyle(color: XColors.grey),
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }
}
