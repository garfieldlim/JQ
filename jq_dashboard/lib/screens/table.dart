import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  Future<void> fetchData(String partition) async {
    final response = await http.get(Uri.parse(
        'https://777d87bd1aca090c7eb23f7eca5207d3.serveo.net/get_data/$partition'));
    if (response.statusCode == 200) {
      var decodedData = json.decode(response.body);
      if (decodedData is Map<String, dynamic>) {
        setState(() {
          data = List<Map<String, dynamic>>.from(decodedData.values);
          _sortData(sortColumn, sortAscending); // Sort data after fetching
        });
      }
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

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(title: const Text('Data Table')),
      body: Column(
        children: [
          DropdownButton<String>(
            value: selectedPartition,
            hint: const Text('Select a partition'),
            onChanged: (String? newValue) {
              setState(() {
                selectedPartition = newValue;
                data = []; // Clear the previous data
              });
            },
            items: partitions.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          ElevatedButton(
            onPressed: () {
              if (selectedPartition != null) {
                fetchData(selectedPartition!);
              }
            },
            child: const Text('Fetch Data'),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: screenWidth,
                ),
                child: DataTable(
                  columnSpacing: screenWidth / 20, // Adjust as needed
                  horizontalMargin: 2, // Adjust as needed
                  sortColumnIndex: sortColumn == null
                      ? null
                      : table_fields[selectedPartition ?? '']
                          ?.indexOf(sortColumn!),
                  sortAscending: sortAscending,
                  columns: [
                    DataColumn(
                      label: const Text('UUID'),
                      onSort: (columnIndex, ascending) {
                        _sortData('uuid', ascending);
                      },
                    ),
                    // Add other columns based on the selected partition
                    ...table_fields[selectedPartition ?? '']
                            ?.map((field) => DataColumn(
                                  label: Text(field.capitalize()),
                                  onSort: (columnIndex, ascending) {
                                    _sortData(field, ascending);
                                  },
                                ))
                            .toList() ??
                        [],
                  ],
                  rows: data.map((item) {
                    return DataRow(
                      cells: [
                        DataCell(Text(item['uuid'] ?? '')),
                        // Add other cells based on the selected partition
                        ...table_fields[selectedPartition ?? '']
                                ?.map((field) =>
                                    DataCell(Text(item[field] ?? '')))
                                .toList() ??
                            [],
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
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
