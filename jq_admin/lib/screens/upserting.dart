import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:http/http.dart' as http;
import 'review.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'field_widgets.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';

class UpsertingPage extends StatefulWidget {
  @override
  _UpsertingPageState createState() => _UpsertingPageState();
}

class _UpsertingPageState extends State<UpsertingPage> {
  final _urlController = TextEditingController();
  String? _selectedSchema = 'Social Posts';
  String _fileName = 'No file uploaded';
  String? _fileContent, _scrapedData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: _backgroundDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(35.0),
        child: _buildGlassContainer(),
      ),
    );
  }

  BoxDecoration _backgroundDecoration() {
    return const BoxDecoration(
      image: DecorationImage(
        image: AssetImage("web/assets/bg.png"),
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildGlassContainer() {
    return GlassmorphicContainer(
      width: 1500,
      height: 750,
      borderRadius: 20,
      blur: 20,
      alignment: Alignment.bottomCenter,
      border: 2,
      linearGradient: _glassLinearGradient(),
      borderGradient: _glassBorderGradient(),
      child: Padding(
        padding: const EdgeInsets.all(35),
        child: _buildContentColumn(),
      ),
    );
  }

  LinearGradient _glassLinearGradient() {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFFeeeeee).withOpacity(0.1),
        const Color(0xFFeeeeee).withOpacity(0.1),
      ],
      stops: [0.1, 1],
    );
  }

  LinearGradient _glassBorderGradient() {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFFeeeeeee).withOpacity(0.5),
        const Color((0xFFeeeeeee)).withOpacity(0.5),
      ],
    );
  }

  Column _buildContentColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _buildSchemaDropdown(),
        const SizedBox(height: 15),
        ..._buildSchemaBasedFields(),
        _buildUploadButton(),
        _buildFileNameText(),
        const SizedBox(height: 15),
        _buildContinueButton(),
      ],
    );
  }

  Widget _buildSchemaDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose Schema:',
          style: TextStyle(color: Colors.white, fontSize: 25),
        ),
        const SizedBox(height: 30),
        DropdownButtonHideUnderline(
          child: DropdownButton2<String>(
            hint: _buildDropdownHint(),
            value: _selectedSchema,
            onChanged: (String? newValue) => setState(() {
              _selectedSchema = newValue!;
            }),
            items: _buildDropdownItems(),
            buttonStyleData: _dropdownButtonStyle(),
            dropdownStyleData: _dropdownStyleData(),
            menuItemStyleData: const MenuItemStyleData(
              height: 40,
              padding: EdgeInsets.all(10.0),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownHint() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      child: Expanded(
        child: Text(
          'Select Schema',
          style: TextStyle(color: Colors.white, fontSize: 18),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> _buildDropdownItems() {
    return <String>['Social Posts', 'Documents', 'People']
        .map<DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Text(
            value,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }).toList();
  }

  ButtonStyleData _dropdownButtonStyle() {
    return ButtonStyleData(
      height: 50,
      width: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white, width: 2),
        color: Colors.transparent,
      ),
    );
  }

  DropdownStyleData _dropdownStyleData() {
    return DropdownStyleData(
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
    );
  }

  List<Widget> _buildSchemaBasedFields() {
    List<Widget> widgets = getFieldsForSelectedSchema(_selectedSchema);
    if (_selectedSchema == 'Social Posts') {
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

  Widget _buildUploadButton() {
    return Center(
      child: ElevatedButton(
        style: _buildElevatedButtonStyle(Colors.transparent, Color(0xff008400)),
        child: const Text('Upload Data File', style: TextStyle(fontSize: 18)),
        onPressed: _pickFile,
      ),
    );
  }

  ButtonStyle _buildElevatedButtonStyle(Color primary, Color onPrimary) {
    return ElevatedButton.styleFrom(
      primary: primary,
      onPrimary: onPrimary,
      elevation: 0,
      side: BorderSide(color: Colors.white, width: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25.0),
      ),
    );
  }

  Widget _buildFileNameText() {
    return Center(
      child: Text(
        _fileName,
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildContinueButton() {
    return Center(
      child: ElevatedButton(
        style: _buildElevatedButtonStyle(Colors.transparent, Color(0xffD9A830)),
        child: const Text('Continue', style: TextStyle(fontSize: 18)),
        onPressed: _handleContinuePress,
      ),
    );
  }

  Future<void> _handleContinuePress() async {
    print('Selected Schema: $_selectedSchema');
    print('File Content: $_fileContent');
    print('URL Text: ${_urlController.text}');

    if (_selectedSchema != null &&
        (_fileContent != null || _urlController.text.isNotEmpty)) {
      if (_selectedSchema == 'Social Posts') {
        if (_urlController.text.isNotEmpty) await _sendUrlToServer();
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
        // If the schema is either 'Documents' or 'People'
        var jsonData = _generateJsonData();
        print(jsonData);
      }
    } else {
      print('Please choose a schema and provide the data');
    }
  }

  String _generateJsonData() {
    var uuid = Uuid().v1(); // Generate a new UUID
    Map<String, String> dataMap = {'uuid': uuid};

    for (var label in controllers.keys) {
      dataMap[label] = controllers[label]!.text;
    }

    return jsonEncode(dataMap); // Convert the map to a JSON string
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom, allowedExtensions: ['pdf', 'jpg', 'png']);

    if (result != null) {
      PlatformFile file = result.files.single;
      _fileContent = base64Encode(file.bytes!);
      setState(() {
        _fileName = file.name;
      });
    } else {
      print('No file picked');
    }
  }

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
