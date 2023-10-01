import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:jq_admin/widgets/glassmorphic.dart';
import 'review.dart';
import 'field_widgets.dart';
import 'package:uuid/uuid.dart';

class SchemaDetailsPage extends StatefulWidget {
  final String schema;

  SchemaDetailsPage({required this.schema});

  @override
  _SchemaDetailsPageState createState() => _SchemaDetailsPageState();
}

class _SchemaDetailsPageState extends State<SchemaDetailsPage> {
  final _urlController = TextEditingController();
  // String _fileName = 'No file uploaded';
  String? _fileContent, _scrapedData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff719382),
      appBar: AppBar(title: Text(widget.schema)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ..._buildSchemaBasedFields(),
            SizedBox(height: 20),
            // _buildFileNameText(),
            SizedBox(height: 20),
            _buildContinueButton(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSchemaBasedFields() {
    List<Widget> widgets = getFieldsForSelectedSchema(widget.schema);
    if (widget.schema == 'Social Posts') {
      widgets.add(TextField(
        controller: _urlController,
        decoration: InputDecoration(
          labelText: 'Enter Facebook URL',
          labelStyle: TextStyle(color: Colors.white),
          border: _buildInputBorderStyle(),
          enabledBorder: _buildInputBorderStyle(),
          focusedBorder: _buildFocusedInputBorderStyle(),
        ),
      ));
    }
    return widgets;
  }

  OutlineInputBorder _buildInputBorderStyle() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.0),
      borderSide: BorderSide(color: Colors.white, width: 2.0),
    );
  }

  OutlineInputBorder _buildFocusedInputBorderStyle() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.0),
      borderSide:
          BorderSide(color: const Color.fromARGB(255, 85, 165, 87), width: 2.0),
    );
  }

  // Widget _buildFileNameText() {
  //   return Center(
  //     child: Text(
  //       _fileName,
  //       style: TextStyle(color: Colors.white),
  //     ),
  //   );
  // }

  Widget _buildContinueButton() {
    return Center(
      child: ElevatedButton(
        // You may need to adjust the styling here as per your needs
        child: const Text('Continue', style: TextStyle(fontSize: 18)),
        onPressed: _handleContinuePress,
      ),
    );
  }

  Future<void> _handleContinuePress() async {
    print('Selected Schema: ${widget.schema}');
    print('File Content: $_fileContent');
    print('URL Text: ${_urlController.text}');

    if (widget.schema != null &&
        (_fileContent != null || _urlController.text.isNotEmpty)) {
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
  }

  String _generateJsonData() {
    var uuid = Uuid().v1(); // Generate a new UUID
    Map<String, String> dataMap = {'uuid': uuid};

    // Assuming you have a controllers map here
    for (var label in controllers.keys) {
      dataMap[label] = controllers[label]!.text;
    }

    return jsonEncode(dataMap); // Convert the map to a JSON string
  }

  // Future<void> _pickFile() async {
  //   FilePickerResult? result = await FilePicker.platform.pickFiles(
  //       type: FileType.custom, allowedExtensions: ['pdf', 'jpg', 'png']);

  //   if (result != null) {
  //     PlatformFile file = result.files.single;
  //     _fileContent = base64Encode(file.bytes!);
  //     setState(() {
  //       _fileName = file.name;
  //     });
  //   } else {
  //     print('No file picked');
  //   }
  // }

  Future<void> _sendUrlToServer() async {
    var url = Uri.parse('http://127.0.0.1:7999/scrape_website');
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
