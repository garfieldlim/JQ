import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:http/http.dart' as http;
import 'review.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'field_widgets.dart';

class UpsertingPage extends StatefulWidget {
  @override
  _UpsertingPageState createState() => _UpsertingPageState();
}

class _UpsertingPageState extends State<UpsertingPage> {
  final _urlController = TextEditingController();

  String? _selectedSchema = 'Social Posts';
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
    var url = Uri.parse('http://127.0.0.1:7999/scrape_website');
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
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
            image: DecorationImage(
          image:
              AssetImage("web/assets/bg.png"), // Replace with your image file
          // Replace with your image file
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
                  const Color(0xFFeeeeee).withOpacity(0.1),
                  const Color(0xFFeeeeee).withOpacity(0.1),
                ],
                stops: [
                  0.1,
                  1,
                ]),
            borderGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFeeeeeee).withOpacity(0.5),
                const Color((0xFFeeeeeee)).withOpacity(0.5),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(35),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'Choose Schema:',
                    style: TextStyle(color: Colors.white, fontSize: 25),
                  ),
                  const SizedBox(height: 30),
                  DropdownButtonHideUnderline(
                    child: DropdownButton2<String>(
                      hint: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: Expanded(
                          child: Text(
                            'Select Schema',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      value: _selectedSchema,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedSchema = newValue!;
                        });
                      },
                      items: <String>['Social Posts', 'Documents', 'People']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Text(
                              value,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        );
                      }).toList(),
                      buttonStyleData: ButtonStyleData(
                        height: 50,
                        width: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                          color: Colors.transparent,
                        ),
                      ),
                      dropdownStyleData: DropdownStyleData(
                        maxHeight: 200,
                        width: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: const Color(0xffFBDFA4),
                        ),
                        scrollbarTheme: ScrollbarThemeData(
                          radius: const Radius.circular(40),
                          thickness: MaterialStateProperty.all(6),
                          thumbVisibility: MaterialStateProperty.all(true),
                        ),
                      ),
                      menuItemStyleData: const MenuItemStyleData(
                        height: 40,
                        padding: EdgeInsets.all(10.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Column(children: getFieldsForSelectedSchema(_selectedSchema)),
                  if (_selectedSchema == 'Social Posts') ...[
                    TextField(
                      controller: _urlController,
                      decoration: InputDecoration(
                        labelText: 'Enter Facebook URL',
                        labelStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.0),
                          borderSide:
                              BorderSide(color: Colors.white, width: 2.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.0),
                          borderSide: BorderSide(
                              color: const Color.fromARGB(255, 85, 165, 87),
                              width: 2.0),
                        ),
                      ),
                    ),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.transparent,
                          onPrimary: Color(0xff008400),
                          elevation: 0,
                          side: BorderSide(color: Colors.white, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                        ),
                        child: const Text('Upload Data File',
                            style: TextStyle(fontSize: 18)),
                        onPressed: _pickFile,
                      ),
                    ),
                    Center(
                      child: Text(
                        _fileName,
                        style: TextStyle(
                          color: Colors.white, // choose the color you prefer
                        ),
                      ),
                    ),
                  ],
                  if (_selectedSchema == 'Documents' ||
                      _selectedSchema == 'People') ...[
                    const SizedBox(height: 15),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.transparent,
                          onPrimary: Color(0xff008400),
                          elevation: 0,
                          side: BorderSide(color: Colors.white, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                        ),
                        child: const Text('Upload Data File',
                            style: TextStyle(fontSize: 18)),
                        onPressed: _pickFile,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Center(
                      child: Text(
                        _fileName,
                        style: TextStyle(
                          color: Colors.white, // choose the color you prefer
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 15),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.transparent,
                        onPrimary: Color(0xffD9A830),
                        elevation: 0,
                        side: BorderSide(color: Colors.white, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                      ),
                      child: const Text('Continue',
                          style: TextStyle(fontSize: 18)),
                      onPressed: () async {
                        // Making onPressed callback asynchronous
                        if (_selectedSchema != null &&
                            (_fileContent != null ||
                                _urlController.text.isNotEmpty)) {
                          if (_urlController.text.isNotEmpty) {
                            await _sendUrlToServer(); // Awaiting _sendUrlToServer method
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReviewPage(
                                schema: _selectedSchema!,
                                data: _urlController.text.isNotEmpty
                                    ? _scrapedData!
                                    : _fileContent!,
                                filePath: '',
                              ),
                            ),
                          );
                        } else {
                          print('Please choose a schema and provide the data');
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
