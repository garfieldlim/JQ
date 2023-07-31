import 'dart:convert';

import 'package:flutter/material.dart';

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
      _textController = TextEditingController(text: firstElement['text']);
      _timeController = TextEditingController(text: firstElement['time']);
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
            image: NetworkImage("assets/bg.png"),
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
                  onPressed: () {
                    print('Schema: ${widget.schema}');
                    print('Text: ${_textController.text}');
                    print('Time: ${_timeController.text}');
                    print('Link: ${_urlController.text}');
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
