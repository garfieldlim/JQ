import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ReviewPage extends StatefulWidget {
  final String schema;
  final String? data;

  ReviewPage(
      {required this.schema, this.data, Key? key, required String filePath})
      : super(key: key);

  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  late TextEditingController _textController;
  late TextEditingController _timeController;
  late TextEditingController _urlController;

  @override
  void initState() {
    super.initState();
    if (widget.data != null) {
      List<dynamic> jsonData = jsonDecode(widget.data!);
      Map<String, dynamic> firstElement =
          jsonData[0]; // getting first element of the list
      _textController =
          TextEditingController(text: firstElement['post_text'].toString());
      _timeController =
          TextEditingController(text: firstElement['time'].toString());
      _urlController = TextEditingController(text: firstElement['post_url']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        width: 1500,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Schema: ${widget.schema}'),
              SizedBox(height: 20),
              if (widget.data != null) ...[
                TextField(
                  controller: _textController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Text',
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _timeController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Time',
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _urlController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Link',
                  ),
                ),
              ],
              SizedBox(height: 35),
              Center(
                child: ElevatedButton(
                  child: const Text(
                    'Upsert',
                    style: TextStyle(fontSize: 18),
                  ),
                  onPressed: () async {
                    final response = await http.post(
                      Uri.parse('http://127.0.0.1:5000/receive_json'),
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
                    } else {
                      print('Failed to send data');
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
