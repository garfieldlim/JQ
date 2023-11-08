import 'package:flutter/material.dart';

class CustomFloatingActionButtonLocation extends FloatingActionButtonLocation {
  final double _offsetY;
  final double _offsetX;

  CustomFloatingActionButtonLocation(this._offsetY, this._offsetX);

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final Offset defaultOffset =
        FloatingActionButtonLocation.endFloat.getOffset(scaffoldGeometry);
    return Offset(defaultOffset.dx - _offsetX, defaultOffset.dy - _offsetY);
  }
}
