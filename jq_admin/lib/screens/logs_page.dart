import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LogsPage extends StatefulWidget {
  @override
  _LogsPageState createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> {
  bool sortByTime = true; // Initially, sort by time

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Logs'),
        actions: [
          IconButton(
            icon: Icon(sortByTime ? Icons.access_time : Icons.thumb_up),
            onPressed: () {
              setState(() {
                sortByTime = !sortByTime;
              });
            },
          ),
        ],
      ),
      body: _buildLogsList(),
    );
  }

  Widget _buildLogsList() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance.collection('chat_messages').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        final logs = snapshot.data!.docs;

        if (sortByTime) {
          // Sort by timestamp (latest first)
          logs.sort((a, b) {
            final aTimestamp =
                (a.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
            final bTimestamp =
                (b.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;

            if (aTimestamp == null || bTimestamp == null) {
              return 0;
            }

            return bTimestamp.toDate().compareTo(aTimestamp.toDate());
          });
        } else {
          // Sort by liked (most liked first)
          logs.sort((a, b) {
            final aLiked =
                (a.data() as Map<String, dynamic>)['liked'] as bool? ?? false;
            final bLiked =
                (b.data() as Map<String, dynamic>)['liked'] as bool? ?? false;

            if (aLiked == bLiked) {
              return 0;
            }

            return aLiked ? -1 : 1;
          });
        }

        // Check if there are any liked messages
        final hasLikedMessages = logs.any(
            (log) => (log.data() as Map<String, dynamic>)['liked'] == true);

        if (!hasLikedMessages) {
          return Center(
            child: Text('Empty'),
          );
        }

        return ListView.builder(
          itemCount: logs.length,
          itemBuilder: (context, index) {
            final log = logs[index].data() as Map<String, dynamic>;
            final documentId = logs[index].id;
            final isUserMessage = log['isUserMessage'] ?? false;
            final partitionName =
                log['partitionName'] ?? ''; // Change to the actual field name
            final milvusData =
                log['milvusData'] ?? ''; // Change to the actual field name

            final timestamp = log['timestamp'] != null
                ? (log['timestamp'] as Timestamp).toDate()
                : DateTime.now();

            final formattedTimestamp =
                '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}';

            return ListTile(
              title: Text(log['text'] ?? ''),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Document ID: $documentId'),
                  if (!isUserMessage) Text('Liked: ${log['liked'] ?? false}'),
                  if (!isUserMessage)
                    Text('Disliked: ${log['disliked'] ?? false}'),
                  Text('Is User Message: $isUserMessage'),
                  Text('Partition Name: $partitionName'),
                  Text('Milvus Data: $milvusData'),
                  Text('Timestamp: $formattedTimestamp'),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
