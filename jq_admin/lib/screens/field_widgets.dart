import 'package:flutter/material.dart';

Map<String, TextEditingController> controllers = {};

List<Widget> getFieldsForSelectedSchema(String? selectedSchema) {
  switch (selectedSchema) {
    case 'Documents':
      return [
        _buildTextField('Text'),
        Row(
          children: [
            Expanded(child: _buildTextField('Author')),
            SizedBox(width: 10),
            Expanded(child: _buildTextField('Title')),
          ],
        ),
        Container(width: 450, child: _buildTextField('Date')),
        _buildTextField('Links'),
      ];
    case 'People':
      return [
        _buildTextField('Text'),
        Row(
          children: [
            Expanded(child: _buildTextField('Name')),
            SizedBox(width: 10),
            Expanded(child: _buildTextField('Media'))
          ],
        ),
        _buildTextField('Links'),
        Row(
          children: [
            Expanded(child: _buildTextField('Position')),
            SizedBox(width: 10),
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
    padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
    margin: EdgeInsets.symmetric(vertical: 10.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20.0),
      boxShadow: [
        BoxShadow(
          color: Color(0xff9c9f78).withOpacity(0.5), // 15% opacity
          spreadRadius: 2,
          blurRadius: 130,
          offset: Offset(0, 46),
        )
      ],
    ),
    child: TextField(
      controller: controllers[label],
      style: TextStyle(
        color: Colors.white,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Color(0xffffe8a4)), // Initial label color
        // Color of label when focused
        fillColor: Color(0xffbec59a), // Background color of input field
        filled: true,
        border: _defaultInputBorder(),
        enabledBorder: _defaultInputBorder(),
        focusedBorder: _focusedInputBorder(),
      ),
    ),
  );
}

InputBorder _defaultInputBorder() {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(14.0),
    borderSide: BorderSide(color: Color(0xffcdcea5), width: 2.0),
  );
}

InputBorder _focusedInputBorder() {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(14.0),
    borderSide: BorderSide(color: const Color(0xffe7d292), width: 2.0),
  );
}
