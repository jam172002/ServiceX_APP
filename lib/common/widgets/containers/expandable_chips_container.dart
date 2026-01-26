import 'package:flutter/material.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

class ExpandableChips extends StatefulWidget {
  final String title;
  final List<String> items;
  final int visibleCount;

  const ExpandableChips({
    super.key,
    required this.title,
    required this.items,
    this.visibleCount = 3,
  });

  @override
  State<ExpandableChips> createState() => _ExpandableChipsState();
}

class _ExpandableChipsState extends State<ExpandableChips> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final displayItems = isExpanded
        ? widget.items
        : widget.items.take(widget.visibleCount).toList();
    final hiddenCount = widget.items.length - displayItems.length;

    return GestureDetector(
      onTap: () => setState(() => isExpanded = !isExpanded),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: XColors.lighterTint),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: XColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                ...displayItems.map(
                  (item) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: XColors.borderColor),
                    ),
                    child: Text(item, style: const TextStyle(fontSize: 12)),
                  ),
                ),
                if (!isExpanded && hiddenCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: XColors.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '+$hiddenCount',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: XColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
