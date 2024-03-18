import 'package:flutter/material.dart';

class NavItem extends StatelessWidget {
  final IconData iconData;
  final VoidCallback onPressed;
  final Color color;
  final String labelText;

  const NavItem({
    super.key,
    required this.iconData,
    required this.onPressed,
    required this.color,
    required this.labelText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Tooltip(
          message: labelText,
          child: IconButton(
            icon: Icon(iconData, color: color),
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }
}
