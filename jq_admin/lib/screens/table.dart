import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart' as http;
import 'package:jq_admin/widgets/palette.dart';
import 'dart:convert';

import '../widgets/data_table_utils.dart';
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
  int itemsPerPage = 4;
  int get _startIndexOfPage => (currentPage - 1) * itemsPerPage;
  int get _endIndexOfPage => _startIndexOfPage + itemsPerPage;

  final TextEditingController searchController = TextEditingController();

  final List<String> partitions = [
    "Select a partition",
    "documents_partition",
    "social_posts_partition",
    "contacts_partition",
    "people_partition"
  ];

  final Map<String, List<String>> table_fields = {
    "documents_partition": ["uuid", "text", "author", "title", "date"],
    "social_posts_partition": ["uuid", "text", "date"],
    "contacts_partition": ["uuid", "name", "text", "contact", "department"],
    "people_partition": ["uuid", "text", "name", "position", "department"],
  };

  Future<void> fetchData(String partition,
      {int page = 1, String? searchQuery}) async {
    var queryParameters = {
      'page': page.toString(),
      'itemsPerPage': itemsPerPage.toString(),
    };

    if (searchQuery != null && searchQuery.isNotEmpty) {
      print("Search Query: $searchQuery"); // Debugging line
      queryParameters['search'] = searchQuery;
    }
    final url =
        Uri.http('127.0.0.1:7999', '/get_data/$partition', queryParameters);

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

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
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
        actions: <Widget>[
          // You can use any widget here. For a logo, typically an Image widget is used.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Image.asset(
                'web/assets/jq.png'), // Replace with your logo asset path
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              width: screenSize.width * 0.99,
              height: screenSize.height * 0.13,
              decoration: BoxDecoration(
                color: const Color(0xffe7dba9),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Container(
                      width: screenSize.width * 0.80,
                      height: screenSize.height * 0.15,
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          labelText: 'Search a log',
                          labelStyle: TextStyle(
                            color: Colors.white,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              searchController.clear();
                              fetchData(selectedPartition!);
                            },
                          ),
                        ),
                        onSubmitted: (value) {
                          fetchData(selectedPartition!, searchQuery: value);
                        },
                        textInputAction: TextInputAction.search,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.search,
                        color: Colors.white), // The search icon
                    label: Text(
                      'Search', // The text label
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      fetchData(selectedPartition!,
                          searchQuery: searchController.text);
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Palette.beige,
                      backgroundColor: const Color(
                          0xfff2c87e), // Background color of the button
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(30.0), // Rounded corners
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: 60.0, vertical: 15.0),
                    ),
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              width: screenSize.width * 0.99,
              height: screenSize.height * 0.10,
              decoration: BoxDecoration(
                color: const Color(0xffe7dba9),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment
                      .spaceBetween, // Space between dropdown and pagination controls
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Color(0xfff2c87e)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButton<String>(
                          underline: Container(),
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
                              child: Text(
                                value,
                                style: const TextStyle(
                                    color: Colors.white), // Text color
                              ),
                            );
                          }).toList(),
                          hint: const Text('Select a partition'),
                          dropdownColor: const Color(0xffe7dba9),
                          iconEnabledColor: Colors.white,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    // Pagination Controls
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back_ios,
                              size: 20, color: Colors.white),
                          onPressed: currentPage > 1
                              ? () {
                                  setState(() {
                                    currentPage--;
                                    fetchData(selectedPartition!,
                                        page: currentPage);
                                  });
                                }
                              : null, // Disable if on the first page
                        ),
                        Text('Page $currentPage',
                            style: TextStyle(color: Colors.white)),
                        IconButton(
                          icon: Icon(Icons.arrow_forward_ios,
                              size: 20, color: Colors.white),
                          onPressed: _endIndexOfPage < data.length
                              ? () {
                                  setState(() {
                                    currentPage++;
                                    fetchData(selectedPartition!,
                                        page: currentPage);
                                  });
                                }
                              : null, // Disable if on the last page
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: screenSize.width * 0.95,
                height: screenSize.height * 0.5,
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
                            color: Colors.grey,
                            width: 2.0, // Set your border width here
                          ),
                          top: BorderSide(
                            color: Colors.grey,
                            width: 2.0, // Set your border width here
                          ),
                        ),
                      ),
                      child: Slidable(
                        key: ValueKey(item['uuid']),
                        // Start action pane (swipe from left to right)
                        startActionPane: ActionPane(
                          motion: const DrawerMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (BuildContext context) {
                                showEditDialog(
                                  context: context,
                                  item: data[actualIndex],
                                  selectedPartition: selectedPartition!,
                                  fields: table_fields[selectedPartition]!,
                                ).then((_) {
                                  fetchData(
                                      selectedPartition!); // Refetch data to refresh the UI
                                });
                              },
                              backgroundColor: Color(0xFFA7C7E7),
                              foregroundColor: Colors.white,
                              icon: Icons.edit,
                              label: 'Edit',
                            ),
                          ],
                        ),
                        // End action pane (swipe from right to left)
                        endActionPane: ActionPane(
                          motion: const DrawerMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (BuildContext context) async {
                                bool success = await deleteItem(
                                    context, item['uuid'], selectedPartition!);
                                if (success) {
                                  setState(() {
                                    data.removeAt(actualIndex);
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text('Item successfully deleted')),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text('Failed to delete the item.')),
                                  );
                                }
                              },
                              backgroundColor: Colors.red,
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
