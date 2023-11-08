// select_type.dart

import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:jq_dashboard/screens/update_knowledgebase_selection/announcements/group_upsertion.dart';
import 'package:jq_dashboard/screens/update_knowledgebase_selection/announcements/single_upsertion.dart';

class SelectTypePage extends StatefulWidget {
  const SelectTypePage({super.key});

  @override
  _SelectTypePageState createState() => _SelectTypePageState();
}

class _SelectTypePageState extends State<SelectTypePage> {
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
      width: 600,
      height: 250,
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
      stops: const [0.1, 1],
    );
  }

  LinearGradient _glassBorderGradient() {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xffeeeeeee).withOpacity(0.5),
        const Color((0xFFeeeeeee)).withOpacity(0.5),
      ],
    );
  }

  Column _buildContentColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _buildOptionButton('Group Upsertion (JSON)'),
        const SizedBox(height: 20),
        _buildOptionButton('Single Upsertion'),
      ],
    );
  }

  Widget _buildOptionButton(String title) {
    return ElevatedButton(
      style: _buildElevatedButtonStyle(Colors.transparent, const Color(0xffD9A830)),
      child: Text(title, style: const TextStyle(fontSize: 18)),
      onPressed: () {
        if (title == 'Group Upsertion (JSON)') {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const GroupUpsertionPage()),
          );
        } else if (title == 'Single Upsertion') {
          // Navigate to the SingleUpsertionPage once you've created it
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const SingleUpsertionPage()),
          );
        }
        print('Selected option: $title');
      },
    );
  }

  ButtonStyle _buildElevatedButtonStyle(Color primary, Color onPrimary) {
    return ElevatedButton.styleFrom(
      foregroundColor: onPrimary, backgroundColor: primary,
      elevation: 0,
      side: const BorderSide(color: Colors.white, width: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25.0),
      ),
    );
  }
}
