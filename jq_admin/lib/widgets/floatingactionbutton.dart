import 'package:flutter/material.dart';

Widget buildFloatingActionButton({required Function() resetChat}) {
  return FloatingActionButton(
      onPressed: resetChat,
      tooltip: 'Reset Chat',
      backgroundColor: const Color(0xfff2c87e),
      child: const Icon(
        Icons.refresh,
        color: Color(0xff969d7b),
      ));
}
