import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SingleUpsertion extends StatefulWidget {
  @override
  _SingleUpsertionState createState() => _SingleUpsertionState();
}

class _SingleUpsertionState extends State<SingleUpsertion> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();

  void _handleSubmit() {
    // Convert the text fields to a JSON object
    Map<String, dynamic> data = {
      "text": _textController.text,
      "name": _nameController.text,
      "position": _positionController.text,
      "department": _departmentController.text,
      "partition_name": "people_partition",
    };

    // Send the JSON data to the server
    _sendDataToServer(data);
  }

  Future<void> _sendDataToServer(Map<String, dynamic> data) async {
    final url =
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upsert People Data')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _textController,
              decoration: InputDecoration(labelText: 'Text'),
            ),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _positionController,
              decoration: InputDecoration(labelText: 'Position'),
            ),
            TextField(
              controller: _departmentController,
              decoration: InputDecoration(labelText: 'Department'),
            ),
            ElevatedButton(onPressed: _handleSubmit, child: Text('Submit')),
          ],
        ),
      ),
    );
  }
}
