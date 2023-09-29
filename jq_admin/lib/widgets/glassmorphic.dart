import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';

class GlassmorphicContainerWidget extends StatelessWidget {
  final double widthPercentage;
  final double heightPercentage;
  final Widget child;
  final Color color1;
  final Color color2;

  GlassmorphicContainerWidget({
    required this.widthPercentage,
    required this.heightPercentage,
    required this.child,
    required this.color1,
    required this.color2,
  });

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width * widthPercentage;
    double height = MediaQuery.of(context).size.height * heightPercentage;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.2), // Adjust color opacity as needed
            spreadRadius: 5,
            blurRadius: 130,
            offset: Offset(0, 16), // Changes position of shadow
          ),
        ],
      ),
      child: GlassmorphicContainer(
        width: width,
        height: height,
        borderRadius: 20,
        blur: 130,
        alignment: Alignment.bottomCenter,
        border: 5,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color1,
            color2,
          ],
          stops: [
            0.1,
            1,
          ],
        ),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color1,
            color2,
          ],
        ),
        child: child,
      ),
    );
  }
}
