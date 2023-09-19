import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class LogsPage extends StatefulWidget {
  @override
  _LogsPageState createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> {
  late CollectionReference logsCollection;
  late Stream<QuerySnapshot> logsStream;

  // Sorting options
  static const List<String> sortingOptions = [
    'Time',
    'User Message',
    'Liked/Disliked'
  ];
  String selectedSortingOption = 'Time';

  @override
  void initState() {
    super.initState();
    logsCollection = FirebaseFirestore.instance.collection('chat_messages');
    logsStream = logsCollection.snapshots();
  }

  String formatTimestamp(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    final formattedDateTime =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
    return formattedDateTime;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Logs Page'),
        actions: [
          // Dropdown menu for sorting options
          DropdownButton<String>(
            value: selectedSortingOption,
            onChanged: (String? newValue) {
              setState(() {
                selectedSortingOption = newValue!;
              });
            },
            items: sortingOptions.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: logsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No data available.'));
          }

          final logs = snapshot.data!.docs;

          // Sort the logs based on the selected sorting option
          logs.sort((a, b) {
            final logDataA = a.data() as Map<String, dynamic>;
            final logDataB = b.data() as Map<String, dynamic>;

            switch (selectedSortingOption) {
              case 'Time':
                final timestampA = logDataA['timestamp'] as Timestamp;
                final timestampB = logDataB['timestamp'] as Timestamp;
                return timestampA.compareTo(timestampB);

              case 'User Message':
                final isUserMessageA = logDataA['isUserMessage'] as bool;
                final isUserMessageB = logDataB['isUserMessage'] as bool;
                return isUserMessageA == isUserMessageB
                    ? 0
                    : isUserMessageA
                        ? -1
                        : 1;

              case 'Liked/Disliked':
                final likedA = logDataA['liked'] as bool? ?? false;
                final likedB = logDataB['liked'] as bool? ?? false;
                return likedA == likedB
                    ? 0
                    : likedA
                        ? -1
                        : 1;

              default:
                return 0;
            }
          });

          return SingleChildScrollView(
            child: DataTable(
              columns: [
                DataColumn(label: Text('Log ID')),
                DataColumn(label: Text('Timestamp')),
                DataColumn(label: Text('Message')),
                DataColumn(label: Text('Is User Message')),
                DataColumn(label: Text('Liked')),
                // Add more DataColumn widgets for other fields
              ],
              rows: logs.map((doc) {
                final logData = doc.data() as Map<String, dynamic>;
                final timestamp = logData['timestamp'] as Timestamp;
                final isUserMessage =
                    logData['isUserMessage'] as bool? ?? false;
                final liked = logData['liked'] as bool? ?? false;

                return DataRow(
                  cells: [
                    DataCell(Text(doc.id)),
                    DataCell(Text(formatTimestamp(timestamp))),
                    DataCell(Text(logData['text'] ?? '')),
                    DataCell(Text(isUserMessage ? 'Yes' : 'No')),
                    DataCell(Text(liked ? 'Yes' : 'No')),
                    // Add more DataCell widgets for other fields
                  ],
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
