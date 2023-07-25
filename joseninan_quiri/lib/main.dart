import 'package:flutter/material.dart';
import 'package:josenian_quiri/screens/homepage.dart';
import 'package:josenian_quiri/screens/login.dart';
import 'package:josenian_quiri/screens/query.dart';
import 'package:josenian_quiri/screens/splashscreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flask Integration',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 255, 223, 107)),
        useMaterial3: true,
      ),
      home: UpsertingPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
