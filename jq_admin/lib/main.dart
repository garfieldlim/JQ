import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:jq_admin/screens/dashboard.dart';
import 'package:jq_admin/screens/query.dart';

// `flutter run -d web-server --web-port 8080 --web-hostname 0.0.0.0 --web-renderer html`

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyBc9BWhNOnGlNOXDgUF-AzrGk3aeb6goq8",
          authDomain: "josenianquiri-c3c63.firebaseapp.com",
          projectId: "josenianquiri-c3c63",
          storageBucket: "josenianquiri-c3c63.appspot.com",
          messagingSenderId: "311772432590",
          appId: "1:311772432590:web:1bc805e7ab29b8daf5e89f"));

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
        fontFamily: 'Lato',
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
