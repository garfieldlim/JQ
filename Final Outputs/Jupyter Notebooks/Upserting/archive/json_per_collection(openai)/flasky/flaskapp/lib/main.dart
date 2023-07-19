import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Flutter API Demo'),
        ),
        body: Center(
          child: ElevatedButton(
            // replace RaisedButton with ElevatedButton
            onPressed: () {
              fetchResults();
            },
            child: Text('Fetch Results'),
          ),
        ),
      ),
    );
  }
}

void fetchResults() async {
  var url = Uri.parse(
      'http://0.0.0.0:7999/search'); // Update to the correct IP and port
  try {
    var response = await http.post(url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode({'question': 'What are the DOST USJR privileges?'}));
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      print('Results: $jsonResponse');
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  } catch (e) {
    print('Request failed with error: $e.');
  }
}
