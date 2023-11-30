import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LogDetailsPage extends StatelessWidget {
  final DocumentSnapshot logSnapshot;

  const LogDetailsPage({Key? key, required this.logSnapshot}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final data = logSnapshot.data() as Map<String, dynamic>;

    return Scaffold(
      backgroundColor: const Color(0xfffff1e4),
      appBar: AppBar(
        title: Text("Log Details", style: TextStyle(color: Color(0XFFF2C87E))),
        backgroundColor: Color(0xff969D7B),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 100.0, vertical: 10.0),
          child: Table(
            border: TableBorder.all(
              color: Color(0xff969D7B), // Change border color here
              width: 1.0, // Change border width here
            ),
            columnWidths: const <int, TableColumnWidth>{
              0: FixedColumnWidth(120.0),
              1: FlexColumnWidth(),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              TableRow(
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
              ...data.entries.map((entry) => TableRow(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          entry.key,
                          style: TextStyle(
                            color: Color(0xff797979), // Change text color here
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          entry.value.toString(),
                          style: TextStyle(
                            color: Color(0xff797979), // Change text color here
                          ),
                        ),
                      ),
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
