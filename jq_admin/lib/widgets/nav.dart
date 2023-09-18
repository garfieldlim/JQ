import 'package:flutter/material.dart';

class NavItem extends StatelessWidget {
  final IconData iconData;
  final VoidCallback onPressed;
  final Color color;

  NavItem(
      {required this.iconData, required this.onPressed, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: IconButton(
        icon: Icon(iconData, color: color),
        onPressed: onPressed,
      ),
    );
  }
}
