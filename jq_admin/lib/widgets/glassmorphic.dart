// widgets/glassmorphic_container_widget.dart
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';

class GlassmorphicContainerWidget extends StatelessWidget {
  final double widthPercentage;
  final double heightPercentage;
  final Widget child;

  GlassmorphicContainerWidget({
    required this.widthPercentage,
    required this.heightPercentage,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width * widthPercentage;
    double height = MediaQuery.of(context).size.height * heightPercentage;

    return GlassmorphicContainer(
      width: width,
      height: height,
      borderRadius: 20,
      blur: 20,
      alignment: Alignment.bottomCenter,
      border: 5,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFaebb9f),
          Color(0xFFaebb9f),
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
          Color(0xFFaebb8f),
          Color((0xFFaebb8f)),
        ],
      ),
      child: child,
    );
  }
}
