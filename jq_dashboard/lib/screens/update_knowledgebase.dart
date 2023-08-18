// update_knowledgebase.dart

import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';

class UpdateKnowledgebasePage extends StatefulWidget {
  @override
  _UpdateKnowledgebasePageState createState() =>
      _UpdateKnowledgebasePageState();
}

class _UpdateKnowledgebasePageState extends State<UpdateKnowledgebasePage> {
  String? _selectedPartition;

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
        child: _buildPartitionDropdown(),
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

  Widget _buildPartitionDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Text(
          'Select Partition:',
          style: TextStyle(color: Colors.white, fontSize: 25),
        ),
        const SizedBox(height: 30),
        DropdownButton<String>(
          hint:
              Text('Choose a partition', style: TextStyle(color: Colors.white)),
          value: _selectedPartition,
          onChanged: (String? newValue) => setState(() {
            _selectedPartition = newValue!;
          }),
          items: ['announcements', 'documents', 'people', 'contacts']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: TextStyle(color: Colors.white)),
            );
          }).toList(),
        ),
      ],
    );
  }
}
