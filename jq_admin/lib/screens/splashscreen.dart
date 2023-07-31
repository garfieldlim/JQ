import 'package:flutter/material.dart';

import 'login.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // navigate to home screen after 5 seconds
    Future.delayed(Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginPage()),
      );
    });

    return Scaffold(
      backgroundColor: Color(0xfffbc44c),
      body: Center(
          child:
              Image.asset('web/asssets/logo.gif')), // replace with your splash gif
    );
  }
}
