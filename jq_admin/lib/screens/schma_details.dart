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
  final _authorController = TextEditingController();
  final _titleController = TextEditingController();
  final _dateController = TextEditingController();
  final _linksController = TextEditingController();
  final _nameController = TextEditingController();
  final _mediaController = TextEditingController();
  final _positionController = TextEditingController();
  final _departmentController = TextEditingController();
  final _textController = TextEditingController();
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
    List<Widget> widgets = [];
    if (widget.schema == 'Social Posts') {
      widgets.add(
        SizedBox(
          width: 900,
          child: TextField(
            controller: _urlController,
            decoration: InputDecoration(
              labelText: 'Enter Facebook URL',
              labelStyle: TextStyle(color: Colors.white),
              border: _buildInputBorderStyle(),
              enabledBorder: _buildInputBorderStyle(),
              focusedBorder: _buildFocusedInputBorderStyle(),
            ),
          ),
        ),
      );
    } else if (widget.schema == "Documents") {
      // Assuming you have controllers for author, title, date, and links
      widgets.addAll([
        TextField(
          controller: _authorController,
          decoration: InputDecoration(
            labelText: 'Author',
            border: _buildInputBorderStyle(),
            enabledBorder: _buildInputBorderStyle(),
            focusedBorder: _buildFocusedInputBorderStyle(),
          ),
        ),
        // textfield for text
        TextField(
          controller: _textController,
          decoration: InputDecoration(
            labelText: 'Text',
            border: _buildInputBorderStyle(),
            enabledBorder: _buildInputBorderStyle(),
            focusedBorder: _buildFocusedInputBorderStyle(),
          ),
        ),
        TextField(
          controller: _titleController,
          decoration: InputDecoration(
            labelText: 'Title',
            border: _buildInputBorderStyle(),
            enabledBorder: _buildInputBorderStyle(),
            focusedBorder: _buildFocusedInputBorderStyle(),
          ),
        ),
        TextField(
          controller: _dateController,
          decoration: InputDecoration(
            labelText: 'Date',
            border: _buildInputBorderStyle(),
            enabledBorder: _buildInputBorderStyle(),
            focusedBorder: _buildFocusedInputBorderStyle(),
          ),
        ),
        TextField(
          controller: _linksController,
          decoration: InputDecoration(
            labelText: 'Links',
            border: _buildInputBorderStyle(),
            enabledBorder: _buildInputBorderStyle(),
            focusedBorder: _buildFocusedInputBorderStyle(),
          ),
        ),
        TextField(
          controller: _mediaController,
          decoration: InputDecoration(
            labelText: 'Media',
            border: _buildInputBorderStyle(),
            enabledBorder: _buildInputBorderStyle(),
            focusedBorder: _buildFocusedInputBorderStyle(),
          ),
        ),
      ]);
    } else if (widget.schema == "People") {
      // Assuming you have controllers for name, media, links, position, and department
      widgets.addAll([
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Name',
            border: _buildInputBorderStyle(),
            enabledBorder: _buildInputBorderStyle(),
            focusedBorder: _buildFocusedInputBorderStyle(),
          ),
        ),
        TextField(
          controller: _textController,
          decoration: InputDecoration(
            labelText: 'Text',
            border: _buildInputBorderStyle(),
            enabledBorder: _buildInputBorderStyle(),
            focusedBorder: _buildFocusedInputBorderStyle(),
          ),
        ),
        TextField(
          controller: _mediaController,
          decoration: InputDecoration(
            labelText: 'Media',
            border: _buildInputBorderStyle(),
            enabledBorder: _buildInputBorderStyle(),
            focusedBorder: _buildFocusedInputBorderStyle(),
          ),
        ),
        TextField(
          controller: _linksController,
          decoration: InputDecoration(
            labelText: 'Links',
            border: _buildInputBorderStyle(),
            enabledBorder: _buildInputBorderStyle(),
            focusedBorder: _buildFocusedInputBorderStyle(),
          ),
        ),
        TextField(
          controller: _positionController,
          decoration: InputDecoration(
            labelText: 'Position',
            border: _buildInputBorderStyle(),
            enabledBorder: _buildInputBorderStyle(),
            focusedBorder: _buildFocusedInputBorderStyle(),
          ),
        ),
        TextField(
          controller: _departmentController,
          decoration: InputDecoration(
            labelText: 'Department',
            border: _buildInputBorderStyle(),
            enabledBorder: _buildInputBorderStyle(),
            focusedBorder: _buildFocusedInputBorderStyle(),
          ),
        ),
      ]);
    }
    return widgets;
  }

  Future<void> _handleContinuePress() async {
    setState(() => _isLoading = true);

    if (widget.schema == 'Social Posts' && _urlController.text.isNotEmpty) {
      await _sendUrlToServer();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReviewPage(
            schema: widget.schema,
            data: _scrapedData!, // Data from server
            filePath:
                '', // Assuming you might have file paths in other use cases
          ),
        ),
      );
    } else if (widget.schema == 'Documents') {
      // Prepare data for "Documents"
      final Map<String, dynamic> data = {
        'author': _authorController.text,
        'text': _textController.text,
        'title': _titleController.text,
        'date': _dateController.text,
        'media': _mediaController.text,
        'links': _linksController.text,
        'partition_name': 'documents_partition',
      };
      await _sendDataToServer(data);
    } else if (widget.schema == 'People') {
      // Prepare data for "People"
      final Map<String, dynamic> data = {
        'name': _nameController.text,
        'text': _textController.text,
        'media': _mediaController.text,
        'links': _linksController.text,
        'position': _positionController.text,
        'department': _departmentController.text,
        'partition_name': 'people_partition',
      };
      await _sendDataToServer(data);
    }

    setState(() => _isLoading = false);
  }

  Future<void> _sendDataToServer(Map<String, dynamic> data) async {
    final String jsonData = json.encode(data);
    // Assuming you have an endpoint URL defined in your constants as upsertURL
    final Uri endpoint = Uri.parse(upsertURL);
    try {
      final response = await http.post(endpoint,
          body: jsonData, headers: {"Content-Type": "application/json"});
      if (response.statusCode == 200) {
        // Handle success
        print("Data sent successfully");
      } else {
        // Handle failure
        print("Failed to send data");
      }
    } catch (e) {
      // Handle error
      print("Error sending data: $e");
    }
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
