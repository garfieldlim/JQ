// In data_table_utils.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
    return true; // Indicate success
  } else {
    return false; // Indicate failure
  }
}

Future<bool> deleteItem(
    BuildContext context, String uuid, String selectedPartition) async {
  bool shouldDelete = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Item'),
          content: const Text('Are you sure you want to delete this item?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      ) ??
      false;

  if (shouldDelete) {
    final Uri url = Uri.http(
        '127.0.0.1:7999', '/delete/$uuid', {'partition': selectedPartition});
    final response = await http.delete(url);

    if (response.statusCode == 200) {
      return true; // Indicate success
    } else {
      return false; // Indicate failure
    }
  }
  return false; // Deletion was not confirmed
}

Future<void> showEditDialog({
  required BuildContext context,
  required Map<String, dynamic> item,
  required String selectedPartition,
  required List<String> fields, // Assuming you pass the fields dynamically
}) async {
  Map<String, TextEditingController> controllers = {};
  for (String field in fields) {
    controllers[field] =
        TextEditingController(text: item[field]?.toString() ?? '');
  }

  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button to close the dialog
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Edit Item'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              const Text('Edit the fields and tap update to save changes.'),
              ...controllers.keys.map((String field) {
                return TextField(
                  controller: controllers[field],
                  decoration: InputDecoration(labelText: field.capitalize()),
                  maxLines: field == 'text'
                      ? null
                      : 1, // Unlimited lines for 'text' field
                  keyboardType: field == 'text'
                      ? TextInputType.multiline
                      : TextInputType.text,
                );
              }),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Update'),
            onPressed: () async {
              // Make this async
              Map<String, dynamic> updatedItem = {};
              for (String field in controllers.keys) {
                updatedItem[field] = controllers[field]?.text ?? '';
              }

              // Now, call editItem with the collected data
              bool success =
                  await editItem(item['uuid'], updatedItem, selectedPartition);
              if (success) {
                // If the update was successful, close the dialog
                Navigator.of(context).pop();
                // Optionally, refresh your data or update the UI as needed
                // For example, you could use a callback or event to inform the parent widget of the update
              } else {
                // Handle failure, e.g., show an error message within the dialog
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content:
                        Text('Failed to update the item. Please try again.')));
              }
            },
          ),
        ],
      );
    },
  );
}

extension on String {
  String capitalize() {
    if (isEmpty) {
      return this;
    }
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
