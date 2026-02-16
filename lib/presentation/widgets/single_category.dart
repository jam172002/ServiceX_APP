import 'package:flutter/material.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

class XSingleCategory extends StatefulWidget {
  final String title;
  final String icon; // can be URL now
  final VoidCallback onTap;

  const XSingleCategory({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  State<XSingleCategory> createState() => _XSingleCategoryState();
}

class _XSingleCategoryState extends State<XSingleCategory>
    with SingleTickerProviderStateMixin {
  double scale = 1.0;


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: MouseRegion(
        onEnter: (_) => setState(() => scale = 0.92),
        onExit: (_) => setState(() => scale = 1.0),
        child: GestureDetector(
          onTapDown: (_) => setState(() => scale = 0.88),
          onTapUp: (_) => setState(() => scale = 1.0),
          onTapCancel: () => setState(() => scale = 1.0),
          onTap: widget.onTap,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 160),
            scale: scale,
            child: Column(
              children: [
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: XColors.lightTint.withValues(alpha: 0.5),
                  ),
              child: (widget.icon.trim().isEmpty)
                  ? const Icon(Icons.category, color: XColors.primary)
                  : (widget.icon.startsWith('http'))
                  ? ColorFiltered(
                colorFilter: const ColorFilter.mode(XColors.primary, BlendMode.srcIn),
                child: Image.network(
                  widget.icon,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(Icons.category, color: XColors.primary),
                ),
              )
                  : Image.asset(
                widget.icon,
                fit: BoxFit.contain,
                color: XColors.primary,
                colorBlendMode: BlendMode.srcIn,
              ),

                ),
                const SizedBox(height: 4),
                Text(
                  widget.title,
                  style: const TextStyle(fontSize: 12, color: XColors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}