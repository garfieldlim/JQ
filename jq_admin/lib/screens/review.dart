import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jq_admin/screens/constants.dart';
import 'package:lottie/lottie.dart';
import 'upserting.dart';

class ReviewPage extends StatefulWidget {
  final String schema;
  final String? data;

  const ReviewPage(
      {required this.schema, this.data, super.key, required String filePath});

  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> with TickerProviderStateMixin {
  late TextEditingController _textController;
  late TextEditingController _timeController;
  late TextEditingController _urlController;
  AnimationController? _controller;
  bool _isUpserting = false;
  bool _isDone = false;

  final Map<String, TextEditingController> controllers = {};

  @override
  void initState() {
    super.initState();

    if (widget.data != null) {
      print('Data: ${widget.data!}');
      List<dynamic> jsonData = jsonDecode(widget.data!);
      Map<String, dynamic> firstElement = jsonData[0];
      _textController =
          TextEditingController(text: firstElement['post_text'].toString());
      _timeController =
          TextEditingController(text: firstElement['time'].toString());
      _urlController = TextEditingController(text: firstElement['post_url']);
    }

    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _controller!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _isDone = false;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const UpsertingPage()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff719382),
      body: Center(
        child: _isUpserting
            ? Icon(Icons.hourglass_empty,
                size: 150,
                color: Colors.white) // Replace with your desired icon
            : (_isDone
                ? Icon(Icons.check_circle_outline,
                    size: 150,
                    color: Colors.white) // Replace with your desired icon
                : _buildBody(context)),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Schema: ${widget.schema}',
            style: TextStyle(
              color: Colors.blue, // Change the color to blue
              fontSize: 24, // Change the font size to 24
            ),
          ),
          const SizedBox(height: 20),
          if (widget.data != null) ...[
            StylizedTextField(label: 'Text', controller: _textController),
            StylizedTextField(label: 'Time', controller: _timeController),
            StylizedTextField(label: 'Link', controller: _urlController),
          ],
          const SizedBox(height: 35),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: const Color(0xffffe8a4),
                backgroundColor: const Color(0xffe7d292),
              ),
              onPressed: _handleUpsertPress,
              child: const Text(
                'Upsert',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleUpsertPress() async {
    setState(() {
      _isUpserting = true;
    });
    final response = await http.post(
      Uri.parse(receiveJsonURL),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'schema': widget.schema,
        'text': _textController.text,
        'time': _timeController.text,
        'url': _urlController.text,
      }),
    );

    if (response.statusCode == 200) {
      print('Data sent successfully');
      // Perform Firestore operation outside of setState
      final Map<String, dynamic> data = {
        'schema': widget.schema,
        'text': _textController.text,
        'time': _timeController.text,
        'url': _urlController.text,
        'partition_name': 'social_posts_partition',
      };
      await FirebaseFirestore.instance.collection('upsertionLogs').add(data);
      setState(() {
        _isUpserting = false;
        _isDone = true;
      });
    } else {
      print('Failed to send data');
      setState(() {
        _isUpserting = false;
      });
    }
  }
}

class StylizedTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const StylizedTextField(
      {super.key, required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff9c9f78).withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 130,
            offset: const Offset(0, 46),
          )
        ],
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xffffe8a4)),
          fillColor: const Color(0xffbec59a),
          filled: true,
          border: _defaultInputBorder(),
          enabledBorder: _defaultInputBorder(),
          focusedBorder: _focusedInputBorder(),
        ),
      ),
    );
  }

  InputBorder _defaultInputBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.0),
      borderSide: const BorderSide(color: Color(0xffcdcea5), width: 2.0),
    );
  }

  InputBorder _focusedInputBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.0),
      borderSide: const BorderSide(color: Color(0xffe7d292), width: 2.0),
    );
  }
}
