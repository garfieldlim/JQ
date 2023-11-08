import 'package:flutter/material.dart';

Map<String, TextEditingController> controllers = {};

List<Widget> getFieldsForSelectedSchema(String? selectedSchema) {
  List<String> fields = _getFieldsForSchema(selectedSchema);

  return [
    for (String label in fields) ...[
      _buildTextField(label),
      const SizedBox(height: 5),
    ]
  ];
}

List<String> _getFieldsForSchema(String? selectedSchema) {
  switch (selectedSchema) {
    case 'Documents':
      return ['Text', 'Author', 'Title', 'Date', 'Links'];
    case 'People':
      return ['Text', 'Name', 'Media', 'Links', 'Position', 'Department'];
    default:
      return [];
  }
}

TextField _buildTextField(String label) {
  controllers.putIfAbsent(label, () => TextEditingController());

  return TextField(
    controller: controllers[label],
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white),
      border: _defaultInputBorder(),
      enabledBorder: _defaultInputBorder(),
      focusedBorder: _focusedInputBorder(),
    ),
  );
}

InputBorder _defaultInputBorder() {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(14.0),
    borderSide: const BorderSide(color: Colors.white, width: 2.0),
  );
}

InputBorder _focusedInputBorder() {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(14.0),
    borderSide:
        const BorderSide(color: Color.fromARGB(255, 85, 165, 87), width: 2.0),
  );
}
