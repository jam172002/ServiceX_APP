import 'package:flutter/material.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

class VipeepProfileStatCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;
  final Color bgColor;
  final VoidCallback? onTap;

  const VipeepProfileStatCard({
    super.key,
    required this.title,
    required this.count,
    required this.icon,
    required this.bgColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Text(
              count,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: XColors.black,
              ),
            ),
            SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w200,
                color: XColors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
