import 'package:flutter/material.dart';

class ExpandableText extends StatefulWidget {
  final String text;
  final int maxLength;

  const ExpandableText({
    super.key,
    required this.text,
    this.maxLength = 50,
  });

  @override
  _ExpandableTextState createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final shouldTruncate = widget.text.length > widget.maxLength;
    final displayText = isExpanded || !shouldTruncate
        ? widget.text
        : '${widget.text.substring(0, widget.maxLength)}...';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          displayText,
          style: const TextStyle(color: Color(0xff4444444)),
        ),
        if (shouldTruncate)
          InkWell(
            child: Icon(
              isExpanded ? Icons.arrow_upward : Icons.arrow_downward,
              color: const Color(0xff638a5e),
            ),
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
          ),
      ],
    );
  }
}
