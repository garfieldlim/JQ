import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LogDetailsPage extends StatelessWidget {
  final DocumentSnapshot logSnapshot;

  const LogDetailsPage({super.key, required this.logSnapshot});

  @override
  Widget build(BuildContext context) {
    final data = logSnapshot.data() as Map<String, dynamic>;

    return Scaffold(
      backgroundColor: const Color(0xfffff1e4),
      appBar: AppBar(
        title: const Text("Log Details", style: TextStyle(color: Color(0XFFF2C87E))),
        backgroundColor: const Color(0xff969D7B),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 100.0, vertical: 10.0),
          child: Container(
            alignment: Alignment.center,
            child: Table(
              border: TableBorder.all(
                color: const Color(0xff969D7B), // Change border color here
                width: 1.0, // Change border width here
              ),
              columnWidths: const <int, TableColumnWidth>{
                0: FixedColumnWidth(120.0),
                1: FlexColumnWidth(),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                const TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Field',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xffF2C87E), // Change text color here
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Value',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xffF2C87E), // Change text color here
                        ),
                      ),
                    ),
                  ],
                ),
                ...data.entries.map((entry) {
                  final key = entry.key;
                  final value = entry.value.toString();
                  return TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          key,
                          style: const TextStyle(
                            color: Color(0xff797979), // Change text color here
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: key == 'milvusData' &&
                                value.length >
                                    50 // Check if it's the Milvus data field
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    value.substring(
                                        0, 50), // Show the first 50 characters
                                    style: const TextStyle(
                                      color: Color(
                                          0xff797979), // Change text color here
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // Implement a function to show more Milvus data
                                      // For example, you can show a dialog with the full Milvus data
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Full Milvus Data'),
                                          content: SingleChildScrollView(
                                            child: Text(
                                              value, // Show the full Milvus data here
                                              style: const TextStyle(
                                                color: Color(
                                                    0xff797979), // Change text color here
                                              ),
                                            ),
                                          ),
                                          actions: [
                                            ElevatedButton(
                                              child: const Text('Close'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'See More',
                                      style: TextStyle(
                                        color: Color(
                                            0xfff2c87e), // Change button text color here
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                value,
                                style: const TextStyle(
                                  color: Color(
                                      0xff797979), // Change text color here
                                ),
                              ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
