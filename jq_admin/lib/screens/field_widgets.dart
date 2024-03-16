import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Map<String, TextEditingController> controllers = {};

List<Widget> getFieldsForSelectedSchema(String? selectedSchema) {
  switch (selectedSchema) {
    case 'Documents':
      return [
        _buildTextField('Text'),
        Row(
          children: [
            Expanded(child: _buildTextField('Author')),
            const SizedBox(width: 10),
            Expanded(child: _buildTextField('Title')),
          ],
        ),
        SizedBox(width: 450, child: _buildTextField('Date')),
        _buildTextField('Links'),
      ];
    case 'People':
      return [
        _buildTextField('Text'),
        Row(
          children: [
            Expanded(child: _buildTextField('Name')),
            const SizedBox(width: 10),
            Expanded(child: _buildTextField('Media'))
          ],
        ),
        _buildTextField('Links'),
        Row(
          children: [
            Expanded(child: _buildTextField('Position')),
            const SizedBox(width: 10),
            Expanded(child: _buildTextField('Department')),
          ],
        ),
      ];
    default:
      return [];
  }
}

Widget _buildTextField(String label) {
  controllers.putIfAbsent(label, () => TextEditingController());

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
    margin: const EdgeInsets.symmetric(vertical: 10.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20.0),
      boxShadow: [
        BoxShadow(
          color: const Color(0xff9c9f78).withOpacity(0.5), // 15% opacity
          spreadRadius: 2,
          blurRadius: 130,
          offset: const Offset(0, 46),
        )
      ],
    ),
    child: TextField(
      controller: controllers[label],
      style: const TextStyle(
        color: Colors.white,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            const TextStyle(color: Color(0xffffe8a4)), // Initial label color
        fillColor: const Color(0xffbec59a), // Background color of input field
        filled: true,
        border: _defaultInputBorder(),
        enabledBorder: _defaultInputBorder(),
        focusedBorder: _focusedInputBorder(),
      ),
      // Here we apply the 1500 character limit
      inputFormatters: [LengthLimitingTextInputFormatter(2500)],
    ),
  );
}

InputBorder _defaultInputBorder() {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(14.0),
    borderSide: const BorderSide(color: Color(0xffcdcea5), width: 2.0),
  );
}

InputBorder _focusedInputBorder() {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(14.0),
    borderSide: const BorderSide(color: Color(0xffe7d292), width: 2.0),
  );
}

Future<void> sendData(Map<String, dynamic> data, String selectedSchema) async {
  final url = Uri.parse('http://<your-flask-server-ip>:<port>/<endpoint>');
  var http;
  await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
    },
    body: json.encode(data),
  );
}

// Assume this function is triggered when a button is pressed
void onSendButtonPressed(String selectedSchema) {
  Map<String, dynamic> dataToSend = {
    'text': controllers['Text']?.text ?? '',
    'author': controllers['Author']?.text ?? '',
    'title': controllers['Title']?.text ?? '',
    'date': controllers['Date']?.text ?? '',
    'links': controllers['Links']?.text ?? '',
    'partition_name': '${selectedSchema}_partition',
  };

  // Adjust the dataToSend map according to the selectedSchema
  // For example, if selectedSchema is 'People', populate the map with relevant keys and values

  sendData(dataToSend, selectedSchema);
}
