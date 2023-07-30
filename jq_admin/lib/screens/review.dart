import 'package:flutter/material.dart';
import 'package:jq_admin/screens/homepage.dart';
import 'package:jq_admin/screens/query.dart';

class ReviewPage extends StatefulWidget {
  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      width: 1500,
      height: 900,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage("assets/bg.png"), // Replace with your image file
          fit: BoxFit.cover,
        ),
      ),
    ));
  }
}
