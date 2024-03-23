import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/data_table_utils.dart';
import '../widgets/expandable.dart';
import '../widgets/table_widgets.dart/pagination.dart';
import '../widgets/table_widgets.dart/searchbar.dart';

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
      // Debugging line
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
          //search log
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SearchWidget(
              searchController: searchController,
              onSearch: () {
                fetchData(selectedPartition!,
                    searchQuery: searchController.text);
              },
            ),
          ),
          //dropdown and pagination
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
                        PaginationControls(
                          currentPage: currentPage,
                          canGoBack: currentPage > 1,
                          canGoForward:
                              true, // Assume there's always a next page for simplicity
                          onPrevious: () {
                            setState(() {
                              currentPage--;
                              fetchData(selectedPartition!, page: currentPage);
                            });
                          },
                          onNext: () {
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
              ),
            ),
          ),
          //table
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Expanded(
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
                          // Edit action
                          SlidableAction(
                            onPressed: (BuildContext context) {
                              showEditDialog(
                                context: context,
                                item: data[actualIndex],
                                selectedPartition: selectedPartition!,
                                fields: table_fields[selectedPartition]!,
                              ).then((_) {
                                // Consider refetching data here or updating the specific item in the list
                                fetchData(
                                    selectedPartition!); // Refetch data to refresh the UI
                              });
                            },
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
                          // Delete action
                          SlidableAction(
                            onPressed: (BuildContext context) async {
                              // Call the deleteItem function
                              bool success = await deleteItem(
                                  context, item['uuid'], selectedPartition!);
                              if (success) {
                                // If the delete was successful, remove the item from your list and update the UI
                                setState(() {
                                  data.removeAt(actualIndex);
                                });
                                // Optionally, show a success message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Item successfully deleted')),
                                );
                              } else {
                                // Handle failure, e.g., show an error message
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
