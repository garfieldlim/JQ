import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:http/http.dart' as http;
import 'review.dart';

class UpsertingPage extends StatefulWidget {
  @override
  _UpsertingPageState createState() => _UpsertingPageState();
}

class _UpsertingPageState extends State<UpsertingPage> {
  final _urlController = TextEditingController();

  String? _selectedSchema;
  String? _fileContent;
  String _fileName = 'No file uploaded';
  String? _scrapedData;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom, allowedExtensions: ['pdf', 'jpg', 'png']);

    if (result != null) {
      PlatformFile file = result.files.single;
      _fileContent = base64Encode(file.bytes!);
      setState(() {
        _fileName = file.name;
      });
      print('Content of the file: $_fileContent');
    } else {
      print('No file picked');
    }
  }

  Future<void> _sendUrlToServer() async {
    var url = Uri.parse('http://127.0.0.1:5000/scrape_website');
    var response = await http.post(
      url,
      body: jsonEncode(
        <String, String>{
          'url': _urlController.text,
        },
      ),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      _scrapedData = response.body;
      print('Server call successful. Response: ${response.body}');
    } else {
      print('Failed to make server call. Status: ${response.statusCode}.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: 1500,
        height: 750,
        decoration: BoxDecoration(
            image: DecorationImage(
          image: NetworkImage("assets/bg.png"), // Replace with your image file
          fit: BoxFit.cover,
        )),
        child: Padding(
          padding: const EdgeInsets.all(35.0),
          child: GlassmorphicContainer(
            width: 1500,
            height: 750,
            borderRadius: 20,
            blur: 20,
            alignment: Alignment.bottomCenter,
            border: 2,
            linearGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFeeeeee).withOpacity(0.1),
                  Color(0xFFeeeeee).withOpacity(0.1),
                ],
                stops: [
                  0.1,
                  1,
                ]),
            borderGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFeeeeeee).withOpacity(0.5),
                Color((0xFFeeeeeee)).withOpacity(0.5),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(35),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Choose Schema:',
                    style: TextStyle(color: Colors.white, fontSize: 25),
                  ),
                  DropdownButton<String>(
                    value: _selectedSchema,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedSchema = newValue!;
                      });
                    },
                    items: <String>['Schema 1', 'Schema 2', 'Schema 3']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    hint: Text('Choose Schema',
                        style: TextStyle(color: Colors.white, fontSize: 20)),
                  ),
                  SizedBox(height: 30),
                  TextField(
                    controller: _urlController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Enter Facebook URL',
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      child: const Text('Upload Data File',
                          style: TextStyle(fontSize: 18)),
                      onPressed: _pickFile,
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(child: Text(_fileName)),
                  SizedBox(height: 35),
                  Center(
                    child: ElevatedButton(
                      child: const Text('Continue',
                          style: TextStyle(fontSize: 18)),
                      onPressed: () {
                        if (_selectedSchema != null &&
                            (_fileContent != null ||
                                _urlController.text.isNotEmpty)) {
                          if (_urlController.text.isNotEmpty) {
                            _sendUrlToServer();
                          }

                          //   Navigator.push(
                          //   //   context,
                          //   //   MaterialPageRoute(
                          //   //     // builder: (context) => ReviewPage(
                          //   //     //   schema: _selectedSchema!,
                          //   //     //   data: _urlController.text.isNotEmpty
                          //   //     //       ? _scrapedData!
                          //   //     //       : _fileContent!,
                          //   //     //   filePath: '',
                          //   //     // ),
                          //   //   ),
                          //   // );
                          // } else {
                          //   print('Please choose a schema and provide the data');
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
