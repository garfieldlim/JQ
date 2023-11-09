import 'package:flutter/material.dart';

Widget buildFloatingActionButton({required Function() resetChat}) {
  return FloatingActionButton(
      onPressed: resetChat,
      tooltip: 'Reset Chat',
      backgroundColor: const Color(0xffdcd8b0),
      child: const Icon(
        Icons.refresh,
        color: Colors.white,
      ));
}
