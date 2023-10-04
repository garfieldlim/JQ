import 'package:flutter/material.dart';

class NavItem extends StatelessWidget {
  final IconData iconData;
  final VoidCallback onPressed;
  final Color color;
  final String labelText; // This is now the tooltip text for the icon

  NavItem({
    required this.iconData,
    required this.onPressed,
    required this.color,
    required this.labelText, // Initialize the labelText in the constructor
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Tooltip(
        message: labelText,
        child: IconButton(
          icon: Icon(iconData, color: color),
          onPressed: onPressed,
        ),
      ),
    );
  }
}
