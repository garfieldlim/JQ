import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SingleUpsertionPage extends StatefulWidget {
  const SingleUpsertionPage({super.key});

  @override
  _SingleUpsertionPageState createState() => _SingleUpsertionPageState();
}

class _SingleUpsertionPageState extends State<SingleUpsertionPage> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _mediaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Single Upsertion for Documents")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField("Title", _titleController),
            const SizedBox(height: 20),
            _buildTextField("Text", _textController),
            const SizedBox(height: 20),
            _buildTextField("Author", _authorController),
            const SizedBox(height: 20),
            _buildTextField("Link", _linkController),
            const SizedBox(height: 20),
            _buildTextField("Date", _dateController),
            const SizedBox(height: 20),
            _buildTextField("Media", _mediaController),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _handleSubmit,
              child: const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  void _handleSubmit() {
    // Convert the text fields to a JSON object
    Map<String, dynamic> data = {
      "text": _textController.text,
      "link": _linkController.text,
      "date": _dateController.text,
      "media": _mediaController.text,
      "title": _titleController.text,
      "author": _authorController.text,
      "partition_name": "documents_partition",
    };

    // Send the JSON data to the server
    _sendDataToServer(data);
  }

  Future<void> _sendDataToServer(Map<String, dynamic> data) async {
    const url =
        'http://127.0.0.1:7999/receive_json'; // Replace with your server address

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      print('Data sent successfully');
    } else {
      print('Failed to send data. Status code: ${response.statusCode}');
    }
  }
}
