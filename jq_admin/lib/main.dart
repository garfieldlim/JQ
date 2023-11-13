import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:jq_admin/screens/dashboard.dart';
import 'package:jq_admin/screens/login.dart';
import 'package:jq_admin/screens/query.dart';

import 'screens/schma_details.dart';
import 'screens/table.dart';
import 'screens/upserting.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyBc9BWhNOnGlNOXDgUF-AzrGk3aeb6goq8",
          appId: "1:311772432590:web:1bc805e7ab29b8daf5e89f",
          messagingSenderId: "311772432590",
          projectId: "josenianquiri-c3c63"));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Josenian Quiri',
      theme: ThemeData(
        // Add the fontFamily property here
        fontFamily: 'JosefinSans',
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 255, 223, 107)),
        useMaterial3: true,
      ),
      home: Admin_dashboard(),
      debugShowCheckedModeBanner: false,
    );
  }
}
