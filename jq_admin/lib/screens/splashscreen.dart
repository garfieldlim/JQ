import 'package:flutter/material.dart';

import 'login.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // navigate to home screen after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    });

    return Scaffold(
      backgroundColor: const Color(0xfffbc44c),
      body: Center(
          child:
              Image.asset('web/asssets/logo.gif')), // replace with your splash gif
    );
  }
}
