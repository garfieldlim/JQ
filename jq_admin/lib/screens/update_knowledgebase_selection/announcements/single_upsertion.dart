import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:http/http.dart' as http;
import 'package:jq_admin/screens/constants.dart';
import 'dart:convert';

import 'package:jq_admin/screens/update_knowledgebase_selection/announcements/single_review.dart';

class SingleUpsertionPage extends StatefulWidget {
  const SingleUpsertionPage({super.key});

  @override
  _SingleUpsertionPageState createState() => _SingleUpsertionPageState();
}

class _SingleUpsertionPageState extends State<SingleUpsertionPage> {
  final _urlController = TextEditingController();
  String? _scrapedData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(35.0),
        child: _buildGlassContainer(),
      ),
    );
  }

  Widget _buildGlassContainer() {
    return GlassmorphicContainer(
      width: 600,
      height: 300,
      borderRadius: 20,
      blur: 20,
      alignment: Alignment.bottomCenter,
      border: 2,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFFeeeeee).withOpacity(0.1),
          const Color(0xFFeeeeee).withOpacity(0.1),
        ],
        stops: const [0.1, 1],
      ),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xffeeeeeee).withOpacity(0.5),
          const Color((0xFFeeeeeee)).withOpacity(0.5),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(35),
        child: _buildContentColumn(),
      ),
    );
  }

  Column _buildContentColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        TextField(
          controller: _urlController,
          decoration: const InputDecoration(
            labelText: 'Enter Facebook URL',
            labelStyle: TextStyle(color: Colors.white),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _sendUrlToServer,
          child: const Text('Continue'),
        ),
      ],
    );
  }

  Future<void> _sendUrlToServer() async {
    var url = Uri.parse(scrapeWebsiteURL);
    var response = await http.post(
      url,
      body: jsonEncode({'url': _urlController.text}),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );

    if (response.statusCode == 200) {
      _scrapedData = response.body;

      // Navigate to ReviewPage on successful scraping
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReviewPage(
            partition_name: "social_posts_partition",
            data: _scrapedData,
            filePath: '',
          ),
        ),
      );
    } else {
      print('Failed to make server call. Status: ${response.statusCode}.');
    }
  }
}
