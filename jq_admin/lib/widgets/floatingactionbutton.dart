import 'package:flutter/material.dart';

Widget buildFloatingActionButton({required Function() resetChat}) {
  return FloatingActionButton(
      onPressed: resetChat,
      tooltip: 'Reset Chat',
      child: Icon(
        Icons.refresh,
        color: Colors.white,
      ),
      backgroundColor: Color(0xffdcd8b0));
}
