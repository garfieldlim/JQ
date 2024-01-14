import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../widgets/expandable.dart';

class DataTableDemo extends StatefulWidget {
  const DataTableDemo({super.key});

  @override
  _DataTableDemoState createState() => _DataTableDemoState();
}

class _DataTableDemoState extends State<DataTableDemo> {
  List<Map<String, dynamic>> data = [];
  String? selectedPartition;
  String? sortColumn;
  bool sortAscending = true;
  int currentPage = 1;
  int itemsPerPage = 10;
  int get _startIndexOfPage => (currentPage - 1) * itemsPerPage;
  int get _endIndexOfPage => _startIndexOfPage + itemsPerPage;

  final List<String> partitions = [
    "documents_partition",
    "social_posts_partition",
    "contacts_partition",
    "people_partition"
  ];

  final Map<String, List<String>> table_fields = {
    "documents_partition": ["text", "author", "title", "date"],
    "social_posts_partition": ["text", "date"],
    "contacts_partition": ["name", "text", "contact", "department"],
    "people_partition": ["text", "name", "position", "department"],
  };

  Future<void> fetchData(String partition, {int page = 1}) async {
    // Construct the URL with query parameters for pagination
    final url = Uri.parse(
        'http://127.0.0.1:7999/get_data/$partition?page=$page&itemsPerPage=$itemsPerPage');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      var decodedData = json.decode(response.body);
      if (decodedData is Map<String, dynamic>) {
        setState(() {
          data = List<Map<String, dynamic>>.from(decodedData.values);
          _sortData(sortColumn, sortAscending); // Sort data after fetching
        });
      }
    } else {
      // Handle error or unsuccessful status code
    }
  }

  void _sortData(String? column, bool ascending) {
    if (column != null) {
      if (ascending) {
        data.sort((a, b) => a[column].compareTo(b[column]));
      } else {
        data.sort((a, b) => b[column].compareTo(a[column]));
      }
      setState(() {
        sortColumn = column;
        sortAscending = ascending;
      });
    }
  }

  Future<void> _showEditDialog(Map<String, dynamic> item) async {
    // Create a map to hold the text controllers for each field
    Map<String, TextEditingController> controllers = {};
    for (String field in table_fields[selectedPartition] ?? []) {
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
                }).toList(),
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
              onPressed: () {
                Map<String, dynamic> updatedItem = {};
                for (String field in controllers.keys) {
                  updatedItem[field] = controllers[field]?.text ?? '';
                }

                // Update the item in the data list
                int indexToUpdate = data
                    .indexWhere((element) => element['uuid'] == item['uuid']);
                if (indexToUpdate != -1) {
                  setState(() {
                    data[indexToUpdate] = updatedItem;
                  });
                }

                // Optionally, send updated data to server...

                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteItem(BuildContext context, Map<String, dynamic> item) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false), // Return false
          ),
          TextButton(
            child: const Text('Delete'),
            onPressed: () => Navigator.of(context).pop(true), // Return true
          ),
        ],
      ),
    );

    // If deletion is confirmed
    if (shouldDelete ?? false) {
      // Implement your delete logic here, e.g., send a DELETE request to the server
      print('Delete item: ${item['uuid']}');
      // For now, just remove the item from the local list and update the state
      setState(() {
        data.removeWhere((element) => element['uuid'] == item['uuid']);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffff1e4),
      appBar: AppBar(
        backgroundColor: const Color(0xfff2c87e),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(); // Go back to previous screen
          },
        ),
        title: const Text(
          'Knowledge Base Logs',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              isExpanded: true,
              value: selectedPartition,
              onChanged: (newValue) {
                setState(() {
                  selectedPartition = newValue;
                  data.clear();
                  fetchData(selectedPartition!);
                });
              },
              items: partitions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  // Apply the text style within DropdownMenuItem
                  child: Text(
                    value,
                    style: const TextStyle(
                        color: Colors.white), // Change text color here
                  ),
                );
              }).toList(),
              hint: const Text('Select a partition'),
              dropdownColor: const Color(0xffe7dba9),
              iconEnabledColor: Colors.white,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          // Headers for the table
          if (selectedPartition != null)
            Row(
              children: table_fields[selectedPartition]!
                  .map(
                    (header) => Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        color: const Color(0xffe7dba9),
                        child: Text(header.capitalize()),
                      ),
                    ),
                  )
                  .toList(),
            ),

          Expanded(
            child: ListView.builder(
              itemCount: _endIndexOfPage <= data.length
                  ? itemsPerPage
                  : data.length - _startIndexOfPage,
              itemBuilder: (context, index) {
                final actualIndex = _startIndexOfPage + index;
                final item = data[actualIndex];
                return DecoratedBox(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey, // Set your border color here
                        width: 2.0, // Set your border width here
                      ),
                    ),
                  ),
                  child: Slidable(
                    key: ValueKey(item['uuid']),
                    startActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (BuildContext context) =>
                              _showEditDialog(item),
                          backgroundColor: const Color(0xFFA7C7E7),
                          foregroundColor: Colors.white,
                          icon: Icons.edit,
                          label: 'Edit',
                        ),
                      ],
                    ),
                    endActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (context) => _deleteItem(context, item),
                          backgroundColor: const Color(0xFFFF6B6B),
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                          label: 'Delete',
                        ),
                      ],
                    ),
                    child: Row(
                      children: table_fields[selectedPartition]!
                          .map(
                            (field) => Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                child: field == 'text'
                                    ? ExpandableText(
                                        text: item[field]?.toString() ?? '')
                                    : Text(item[field]?.toString() ?? ''),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: currentPage > 1
                    ? () {
                        setState(() {
                          currentPage--;
                          fetchData(selectedPartition!, page: currentPage);
                        });
                      }
                    : null,
              ),
              Text('Page $currentPage'),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: () {
                  setState(() {
                    currentPage++;
                    fetchData(selectedPartition!, page: currentPage);
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
