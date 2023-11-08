// update_knowledgebase.dart

import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:jq_dashboard/screens/update_knowledgebase_selection/announcements/select_type.dart'
    as announcements;
import 'package:jq_dashboard/screens/update_knowledgebase_selection/documents/select_type.dart'
    as documents;
import 'package:jq_dashboard/screens/update_knowledgebase_selection/people/select_type.dart'
    as people;

class UpdateKnowledgebasePage extends StatefulWidget {
  const UpdateKnowledgebasePage({super.key});

  @override
  _UpdateKnowledgebasePageState createState() =>
      _UpdateKnowledgebasePageState();
}

class _UpdateKnowledgebasePageState extends State<UpdateKnowledgebasePage> {
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
      width: 800,
      height: 400,
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
        _buildPartitionButton('announcements'),
        const SizedBox(height: 20),
        _buildPartitionButton('documents'),
        const SizedBox(height: 20),
        _buildPartitionButton('people'),
        const SizedBox(height: 20),
        _buildPartitionButton('contacts'),
      ],
    );
  }

  Widget _buildPartitionButton(String title) {
    return ElevatedButton(
      style: _buildElevatedButtonStyle(Colors.transparent, const Color(0xffD9A830)),
      child: Text(title, style: const TextStyle(fontSize: 18)),
      onPressed: () {
        if (title == 'announcements') {
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => const announcements.SelectTypePage()),
          );
        }
        if (title == 'documents') {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const documents.SelectTypePage()),
          );
        }
        if (title == 'people') {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const people.SelectTypePage()),
          );
        }
        // Handle other partition selections here
        print('Selected partition: $title');
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
