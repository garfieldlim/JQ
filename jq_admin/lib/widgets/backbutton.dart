import 'package:flutter/material.dart';
import 'package:jq_admin/widgets/palette.dart';

class BackButtonWidget extends StatelessWidget {
  final Color? color;

  const BackButtonWidget({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          const EdgeInsets.all(8), // Adjust based on your layout preferences
      decoration: BoxDecoration(
        color:
            Palette.color5, // Assuming a light theme for the neumorphic effect
        shape: BoxShape.circle,
        boxShadow: [
          // Light source shadow
          BoxShadow(
            color: Colors.white.withOpacity(0.8), // Light shadow color
            offset: Offset(-4, -4),
            blurRadius: 10,
            spreadRadius: 1,
          ),
          // Simulated shadow on bottom right; slightly darker to enhance contrast
          BoxShadow(
            color: Colors.brown[100]!
                .withOpacity(0.5), // Darker shadow for contrast
            offset: Offset(4, 4),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Tooltip(
        message: "Back",
        child: IconButton(
          icon: Icon(Icons.arrow_back,
              color: color ??
                  Colors.grey[600]), // Icon color adjusted for visibility
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
