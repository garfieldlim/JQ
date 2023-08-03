import 'package:flutter/material.dart';

Map<String, TextEditingController> controllers = {};

List<Widget> getFieldsForSelectedSchema(String? selectedSchema) {
  List<String> fields = [];
  if (selectedSchema == 'Documents') {
    fields = ['Text', 'Author', 'Title', 'Date', 'Media (link)', 'Link'];
  } else if (selectedSchema == 'People') {
    fields = ['Text', 'Name', 'Media', 'Links', 'Position', 'Department'];
  } else {
    return [];
  }
  return fields.map((label) => buildTextField(label)).toList();
}

TextField buildTextField(String label) {
  controllers.putIfAbsent(label, () => TextEditingController());
  return TextField(
    controller: controllers[label],
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.0),
        borderSide: BorderSide(color: Colors.white, width: 2.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.0),
        borderSide: BorderSide(
            color: const Color.fromARGB(255, 85, 165, 87), width: 2.0),
      ),
    ),
  );
}
