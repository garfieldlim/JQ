import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jq_admin/screens/constants.dart';
import 'review.dart';
import 'field_widgets.dart';
import 'package:uuid/uuid.dart';

class SchemaDetailsPage extends StatefulWidget {
  final String schema;

  const SchemaDetailsPage({super.key, required this.schema});

  @override
  _SchemaDetailsPageState createState() => _SchemaDetailsPageState();
}

class _SchemaDetailsPageState extends State<SchemaDetailsPage> {
  final _urlController = TextEditingController();
  String? _fileContent, _scrapedData;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff969d7b),
      appBar: AppBar(
        backgroundColor: const Color(0xfffff1e4),
        title: Text(
          widget.schema,
          style: const TextStyle(color: Color(0xfff2c87e)),
        ),
        leading: const BackButton(
          color: Color(0xfff2c87e),
        ),
      ),
      body: Center(
        child: _isLoading
            ? Image.asset('web/assets/logo.gif')
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 300,
                    padding: const EdgeInsets.all(16.0),
                    child: Image.asset('web/assets/jq.png'),
                  ),
                  ..._buildSchemaBasedFields(),
                  const SizedBox(height: 20),
                  const SizedBox(height: 20),
                  _buildContinueButton(),
                ],
              ),
      ),
    );
  }

  List<Widget> _buildSchemaBasedFields() {
    List<Widget> widgets = getFieldsForSelectedSchema(widget.schema);
    if (widget.schema == 'Social Posts') {
      widgets.add(
        SizedBox(
          width: 900,
          child: TextField(
            controller: _urlController,
            decoration: InputDecoration(
              labelText: 'Enter Facebook URL',
              labelStyle: const TextStyle(color: Colors.white),
              border: _buildInputBorderStyle(),
              enabledBorder: _buildInputBorderStyle(),
              focusedBorder: _buildFocusedInputBorderStyle(),
            ),
          ),
        ),
      );
    }
    return widgets;
  }

  OutlineInputBorder _buildInputBorderStyle() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.0),
      borderSide: const BorderSide(color: Color(0xfff2c87e), width: 2.0),
    );
  }

  OutlineInputBorder _buildFocusedInputBorderStyle() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.0),
      borderSide: const BorderSide(color: Color(0xfff2c87e), width: 2.0),
    );
  }

  Widget _buildContinueButton() {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: const Color(0xffffe8a4),
          backgroundColor:
              const Color(0xffe7d292), // This is the color of the text
        ),
        onPressed: _handleContinuePress,
        child: const Text('Continue', style: TextStyle(fontSize: 18)),
        // You may need to adjust the styling here as per your needs
        // child: const Text('Continue', style: TextStyle(fontSize: 18)),
      ),
    );
  }

  Future<void> _handleContinuePress() async {
    setState(() {
      _isLoading = true;
    });

    print('Selected Schema: ${widget.schema}');
    print('File Content: $_fileContent');
    print('URL Text: ${_urlController.text}');

    if ((_fileContent != null || _urlController.text.isNotEmpty)) {
      if (widget.schema == 'Social Posts') {
        if (_urlController.text.isNotEmpty) await _sendUrlToServer();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReviewPage(
              schema: widget.schema,
              data: _urlController.text.isNotEmpty
                  ? _scrapedData!
                  : _fileContent!,
              filePath: '',
            ),
          ),
        );
      } else {
        // If the schema is either 'Documents' or 'People'
        var jsonData = _generateJsonData();
        print(jsonData);
      }
    } else {
      print('Please provide the data');
    }

    setState(() {
      _isLoading = false; // End loading once done
    });
  }

  String _generateJsonData() {
    var uuid = const Uuid().v1(); // Generate a new UUID
    Map<String, String> dataMap = {'uuid': uuid};

    // Assuming you have a controllers map here
    for (var label in controllers.keys) {
      dataMap[label] = controllers[label]!.text;
    }

    return jsonEncode(dataMap); // Convert the map to a JSON string
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
    } else {
      print('Failed to make server call. Status: ${response.statusCode}.');
    }
  }
}
