import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

class SearchWithFilter extends StatelessWidget {
  final VoidCallback? onFilterTap;
  final String hintText;
  final IconData searchIcon;
  final IconData filterIcon;
  final double horPadding;
  final bool showFilter;
  final TextEditingController? controller;
  final Function(String)? onChanged;

  const SearchWithFilter({
    super.key,
    this.onFilterTap,
    this.hintText = 'Looking For ...',
    this.searchIcon = Iconsax.search_normal,
    this.filterIcon = Iconsax.setting_4,
    required this.horPadding,
    this.showFilter = true,
    this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    final double searchHeight = height * 0.06;
    final double iconSize = width * 0.05;
    final double padding = width * 0.04;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horPadding),
      child: SizedBox(
        height: searchHeight,
        child: Row(
          children: [
            // Search input
            Expanded(
              flex: showFilter ? 5 : 6,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: padding),
                decoration: BoxDecoration(
                  color: XColors.secondaryBG,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: XColors.borderColor, width: 0.7),
                ),
                child: Row(
                  children: [
                    Icon(searchIcon, color: XColors.success, size: iconSize),
                    SizedBox(width: width * 0.02),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        onChanged: onChanged,
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: width * 0.035,
                        ),
                        decoration: InputDecoration(
                          hintText: hintText,
                          hintStyle: TextStyle(
                            color: XColors.grey,
                            fontSize: width * 0.03,
                            fontWeight: FontWeight.w300,
                          ),
                          border: InputBorder.none, // ✅ remove inner border
                          focusedBorder:
                              InputBorder.none, // ✅ remove focus border
                          enabledBorder:
                              InputBorder.none, // ✅ remove enabled border
                          disabledBorder:
                              InputBorder.none, // ✅ remove disabled border
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: searchHeight * 0.25,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // spacing if filter is visible
            if (showFilter) SizedBox(width: width * 0.025),

            // Filter button
            if (showFilter)
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: onFilterTap,
                  child: Container(
                    padding: EdgeInsets.all(width * 0.03),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: XColors.primary,
                    ),
                    child: Icon(
                      filterIcon,
                      size: iconSize,
                      color: XColors.secondaryBG,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
