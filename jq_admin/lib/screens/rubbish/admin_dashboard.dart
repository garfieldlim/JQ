import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:jq_admin/screens/logs_page.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: _backgroundDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(35.0),
        child: _buildGlassContainer(),
      ),
    );
  }

  BoxDecoration _backgroundDecoration() {
    return const BoxDecoration(
      image: DecorationImage(
        image: AssetImage("web/assets/bg.png"),
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildGlassContainer() {
    return GlassmorphicContainer(
      width: 1500,
      height: 800,
      borderRadius: 20,
      blur: 20,
      alignment: Alignment.bottomCenter,
      border: 2,
      linearGradient: _glassLinearGradient(),
      borderGradient: _glassBorderGradient(),
      child: Padding(
        padding: const EdgeInsets.all(35),
        child: _buildContentColumn(),
      ),
    );
  }

  LinearGradient _glassLinearGradient() {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFFeeeeee).withOpacity(0.1),
        const Color(0xFFeeeeee).withOpacity(0.1),
      ],
      stops: [0.1, 1],
    );
  }

  LinearGradient _glassBorderGradient() {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFFeeeeeee).withOpacity(0.5),
        const Color((0xFFeeeeeee)).withOpacity(0.5),
      ],
    );
  }

  Column _buildContentColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _buildDashboardButton('Update knowledgebase'),
        const SizedBox(height: 20),
        _buildDashboardButton('View knowledgebase'),
        const SizedBox(height: 20),
        _buildDashboardButton('Logs'),
      ],
    );
  }

  Widget _buildDashboardButton(String title) {
    return ElevatedButton(
      style: _buildElevatedButtonStyle(Colors.transparent, Color(0xffD9A830)),
      child: Text(title, style: TextStyle(fontSize: 18)),
      onPressed: () {
        if (title == 'Logs') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LogsPage()),
          );
        } else {
          // Handle other button presses
          print('$title button pressed');
        }
      },
    );
  }

  ButtonStyle _buildElevatedButtonStyle(Color primary, Color onPrimary) {
    return ElevatedButton.styleFrom(
      primary: primary,
      onPrimary: onPrimary,
      elevation: 0,
      side: BorderSide(color: Colors.white, width: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25.0),
      ),
      padding: EdgeInsets.symmetric(horizontal: 100, vertical: 20),
    );
  }
}
