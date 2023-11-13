import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LogDetailsPage extends StatelessWidget {
  final DocumentSnapshot logSnapshot;

  const LogDetailsPage({Key? key, required this.logSnapshot}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final data = logSnapshot.data() as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(title: Text("Log Details")),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Table(
          border: TableBorder.all(),
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
                  child: Text('Field',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Value',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            ...data.entries.map((entry) => TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(entry.key),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(entry.value.toString()),
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
