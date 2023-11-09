// group_upsertion.dart

import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:file_picker/file_picker.dart';

class GroupUpsertionPage extends StatefulWidget {
  const GroupUpsertionPage({super.key});

  @override
  _GroupUpsertionPageState createState() => _GroupUpsertionPageState();
}

class _GroupUpsertionPageState extends State<GroupUpsertionPage> {
  String _fileName = 'No file uploaded';

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
        _buildFormatGuide(),
        const SizedBox(height: 20),
        _buildUploadButton(),
        const SizedBox(height: 20),
        _buildContinueButton(),
      ],
    );
  }

  Widget _buildFormatGuide() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Format Guide:',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        Text(
          '{\ntext: <text_content>,\nlink: <link_content>,\ntime: <time_content>\n}',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ],
    );
  }

  Widget _buildUploadButton() {
    return Center(
      child: ElevatedButton(
        style: _buildElevatedButtonStyle(Colors.transparent, const Color(0xffD9A830)),
        onPressed: _pickFile,
        child: const Text('Upload JSON File', style: TextStyle(fontSize: 18)),
      ),
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

  Widget _buildContinueButton() {
    return Center(
      child: ElevatedButton(
        style: _buildElevatedButtonStyle(Colors.transparent, const Color(0xffD9A830)),
        child: const Text('Continue', style: TextStyle(fontSize: 18)),
        onPressed: () {
          // Handle continue press
          print('Continue button pressed');
        },
      ),
    );
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['json']);

    if (result != null) {
      setState(() {
        _fileName = result.files.single.name;
      });
    } else {
      print('No file picked');
    }
  }
}
