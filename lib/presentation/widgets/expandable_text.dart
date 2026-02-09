import 'package:flutter/material.dart';

class ExpandableText extends StatefulWidget {
  final String text;
  final int maxLines;
  final Color textColor;
  final double textSize;

  const ExpandableText({
    super.key,
    required this.text,
    this.maxLines = 2,
    this.textColor = Colors.black87,
    this.textSize = 14,
  });

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isExpanded = !isExpanded;
        });
      },
      child: Text(
        widget.text,
        maxLines: isExpanded ? null : widget.maxLines,
        overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
        style: TextStyle(fontSize: widget.textSize, color: widget.textColor),
      ),
    );
  }
}
