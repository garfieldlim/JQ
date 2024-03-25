import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Assumes 'editItem' function remains unchanged from your current implementation.
Future<bool> editItem(String uuid, Map<String, dynamic> updatedItem,
    String selectedPartition) async {
  final Uri url = Uri.http(
      '127.0.0.1:7999', '/edit/$uuid', {'partition': selectedPartition});
  final response = await http.put(
    url,
    body: json.encode(updatedItem),
    headers: {"Content-Type": "application/json"},
  );

  if (response.statusCode == 200) {
    print('Request URL: $url');
    print('Request Body: ${json.encode(updatedItem)}');
    return true; // Indicate success
  } else {
    print('Error updating item: ${response.body}');
    return false; // Indicate failure
  }
}

// Updated showEditDialog function with returning Future<bool> indicating the operation success
Future<bool> showEditDialog({
  required BuildContext context,
  required Map<String, dynamic> item,
  required String selectedPartition,
  required List<String> fields,
}) async {
  Map<String, TextEditingController> controllers = {};
  for (String field in fields) {
    controllers[field] =
        TextEditingController(text: item[field]?.toString() ?? '');
  }

  return await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text('Edit Item'),
            content: SingleChildScrollView(
              child: ListBody(
                children: fields
                    .map((field) => TextField(
                          controller: controllers[field],
                          decoration:
                              InputDecoration(labelText: field.capitalize()),
                          keyboardType: TextInputType.text,
                        ))
                    .toList(),
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(dialogContext).pop(false),
              ),
              TextButton(
                child: const Text('Update'),
                onPressed: () async {
                  Map<String, dynamic> updatedItem = {};
                  for (String field in controllers.keys) {
                    updatedItem[field] = controllers[field]!.text;
                  }

                  bool success = await editItem(
                      item['uuid'], updatedItem, selectedPartition);
                  Navigator.of(dialogContext).pop(success);
                },
              ),
            ],
          );
        },
      ) ??
      false; // Handle dialog dismissal by returning false
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }
}
