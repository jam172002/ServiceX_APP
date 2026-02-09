import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

class XAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackIcon;
  final List<Widget>? actions;

  const XAppBar({
    super.key,
    required this.title,
    this.showBackIcon = true,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: showBackIcon
          ? IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.black87,
                size: 20,
              ),
              onPressed: () => Get.back(),
            )
          : null,
      centerTitle: true,
      title: Text(
        title,
        style: const TextStyle(
          color: XColors.black,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
