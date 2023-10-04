import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:jq_admin/screens/rubbish/admin_dashboard.dart';
import 'package:jq_admin/screens/dashboard.dart';
import 'package:jq_admin/screens/login.dart';
import 'package:jq_admin/screens/logs_page.dart';
import 'package:jq_admin/screens/query.dart';
import 'package:jq_admin/screens/splashscreen.dart';
import 'package:jq_admin/screens/upserting.dart';
import 'package:jq_admin/screens/review.dart';
import 'package:jq_admin/screens/query.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyBc9BWhNOnGlNOXDgUF-AzrGk3aeb6goq8",
          appId: "1:311772432590:web:1bc805e7ab29b8daf5e89f",
          messagingSenderId: "311772432590",
          projectId: "josenianquiri-c3c63"));

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Josenian Quiri',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 255, 223, 107)),
        useMaterial3: true,
      ),
      home: Admin_dashboard(),
      debugShowCheckedModeBanner: false,
    );
  }
}
