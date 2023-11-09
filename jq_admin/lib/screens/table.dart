import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DataTableDemo extends StatefulWidget {
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
    final response =
        await http.get(Uri.parse('http://127.0.0.1:7999/get_data/$partition'));
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

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Color(0xffffe8a4)),
        title: const Text(
          'Knowledge Base Logs',
          style: TextStyle(color: Color(0xffffe8a4)),
        ),
        backgroundColor: const Color(0xffbdc499),
      ),
      backgroundColor: const Color(0xffafbb8f),
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 75.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: DropdownButton<String>(
                  dropdownColor: const Color(0xffbdc499),
                  style: const TextStyle(
                      color: Color(
                          0xff638a7e)), // Default style for dropdown items
                  icon: const Icon(Icons.arrow_downward,
                      color: Color(0xff638a7e)), // Custom dropdown icon
                  underline: Container(
                    height: 2,
                    color: const Color(0xff638a7e), // Underline color
                  ),
                  value: selectedPartition,
                  hint: Text('Select a partition'),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedPartition = newValue;
                      data = [];
                    });
                    if (newValue != null) {
                      fetchData(newValue);
                    }
                  },
                  items:
                      partitions.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: const TextStyle(
                              color: Color(
                                  0xff638a7e)), // Override default style if needed
                        ));
                  }).toList(),
                ),
              ),
            ),

            data.isNotEmpty
                ? Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Card(
                          color: const Color(0xffbec59a),
                          elevation: 5.0,
                          child: DataTable(
                            columnSpacing: screenWidth / 20,
                            horizontalMargin: 5,
                            sortColumnIndex: sortColumn == null
                                ? null
                                : table_fields[selectedPartition ?? '']
                                    ?.indexOf(sortColumn!),
                            sortAscending: sortAscending,
                            columns: [
                              DataColumn(
                                label: const Text(
                                  'UUID',
                                  style: TextStyle(color: Color(0xff638a7e)),
                                ),
                                onSort: (columnIndex, ascending) {
                                  _sortData('uuid', ascending);
                                },
                              ),
                              ...?(table_fields[selectedPartition ?? ''] ?? [])
                                      .map((field) => DataColumn(
                                            label: Text(
                                              field.capitalize(),
                                              style: const TextStyle(
                                                  color: Color(0xff638a7e)),
                                            ),
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
                                  DataCell(Text(
                                    item['uuid'] ?? '',
                                    style: TextStyle(color: Color(0xffffe8a4)),
                                  )),
                                  ...?(table_fields[selectedPartition ?? ''] ??
                                              [])
                                          .map((field) => DataCell(
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        item[field]
                                                                    .toString()
                                                                    .length >
                                                                50
                                                            ? item[field]
                                                                    .toString()
                                                                    .substring(
                                                                        0, 47) +
                                                                "..."
                                                            : item[field]
                                                                .toString(),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xffffe8a4)),
                                                      ),
                                                    ),
                                                    if (item[field]
                                                            .toString()
                                                            .length >
                                                        50)
                                                      TextButton(
                                                        onPressed: () {
                                                          showDialog(
                                                            context: context,
                                                            builder:
                                                                (context) =>
                                                                    AlertDialog(
                                                              backgroundColor:
                                                                  Color(
                                                                      0xffffe8a4),
                                                              content: Text(
                                                                  item[field]
                                                                      .toString(),
                                                                  style: TextStyle(
                                                                      color: Color(
                                                                          0xff719382))),
                                                            ),
                                                          );
                                                        },
                                                        child: Text('See More',
                                                            style: TextStyle(
                                                                color: Color(
                                                                    0xff638a5e))),
                                                      ),
                                                  ],
                                                ),
                                              ))
                                          .toList() ??
                                      [],
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  )
                : Container() // Show an empty Container when no data is fetched
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
