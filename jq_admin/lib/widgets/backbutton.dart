import 'package:flutter/material.dart';

class BackButtonWidget extends StatelessWidget {
  final Color? color;

  const BackButtonWidget({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back, color: color ?? Colors.white),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }
}
