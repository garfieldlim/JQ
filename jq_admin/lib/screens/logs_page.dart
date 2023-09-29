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

  @override
  void initState() {
    super.initState();
    logsCollection = FirebaseFirestore.instance.collection('chat_messages');
    logsStream = logsCollection.snapshots();
  }

  Widget _buildHorizontalLogList({required bool sortByTime}) {
    return StreamBuilder<QuerySnapshot>(
      stream: logsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        List<DocumentSnapshot> logs = snapshot.data!.docs;

        if (logs.isEmpty) {
          return Center(child: Text('No data available.'));
        }

        if (sortByTime) {
          logs.sort((a, b) {
            final aTimestamp = a.get('timestamp') as Timestamp?;
            final bTimestamp = b.get('timestamp') as Timestamp?;
            if (aTimestamp == null || bTimestamp == null) {
              return 0;
            }
            return bTimestamp.toDate().compareTo(aTimestamp.toDate());
          });
        } else {
          logs.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;

            final aLiked = aData['liked'] as bool? ?? false;
            final bLiked = bData['liked'] as bool? ?? false;

            return aLiked == bLiked ? 0 : (aLiked ? -1 : 1);
          });
        }

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: logs.length,
          itemBuilder: (context, index) {
            final log = logs[index].data() as Map<String, dynamic>;
            final documentId = logs[index].id;
            final isUserMessage = log['isUserMessage'] ?? false;
            final partitionName = log['partitionName'] ?? '';
            final milvusData = log['milvusData'] ?? '';

            final timestamp = log['timestamp'] != null
                ? (log['timestamp'] as Timestamp).toDate()
                : DateTime.now();

            final formattedTimestamp =
                '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}';

            return SizedBox(
              width: 300,
              child: ClipRect(
                child: OverflowBox(
                  alignment: Alignment.center,
                  child: Container(
                    margin: EdgeInsets.all(8.0),
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                        )
                      ],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          log['text'] ?? '',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 3, // Adjust the number of lines as needed
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 10),
                        Text('Document ID: $documentId'),
                        if (!isUserMessage)
                          Text('Liked: ${log['liked'] ?? false}'),
                        if (!isUserMessage)
                          Text('Disliked: ${log['disliked'] ?? false}'),
                        Text('Is User Message: $isUserMessage'),
                        Text('Partition Name: $partitionName'),
                        Text('Milvus Data: $milvusData'),
                        Text('Timestamp: $formattedTimestamp'),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text('Logs', style: TextStyle(fontSize: 30)),
          ),
          // Recently Added Section
          SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              "Recently Added",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
              height: 220, child: _buildHorizontalLogList(sortByTime: true)),
          SizedBox(height: 25),
          // Most Liked Section
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              "Most Liked",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
              height: 220, child: _buildHorizontalLogList(sortByTime: false)),
        ],
      ),
    );
  }
}
