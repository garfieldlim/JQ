import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Widget buildHorizontalLogList({
  required Stream<QuerySnapshot> logsStream,
  required bool sortByTime,
  required bool sortByLikes,
  required bool sortByDislikes,
  required void Function(DocumentSnapshot) showLogDetails,
}) {
  return StreamBuilder<QuerySnapshot>(
    stream: logsStream,
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }

      var logs = snapshot.data!.docs;

      if (sortByTime) {
        logs.sort((a, b) {
          final aTimestampString = a.get('timestamp') as String;
          final bTimestampString = b.get('timestamp') as String;
          final aDateTime = DateTime.parse(aTimestampString);
          final bDateTime = DateTime.parse(bTimestampString);
          return bDateTime.compareTo(aDateTime); // Sorting in descending order.
        });
      } else if (sortByLikes) {
        logs = logs.where((log) => log.get('liked') == true).toList();
      } else if (sortByDislikes) {
        // Filter out logs with 'liked' = true
        logs = logs.where((log) => log.get('liked') != true).toList();
        // No need to sort since all remaining should be disliked or neutral
      }

      if (logs.isEmpty) {
        return const Center(child: Text('No data available.'));
      }

      return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: logs.length,
        itemBuilder: (context, index) {
          final DocumentSnapshot logSnapshot = logs[index];
          final Map<String, dynamic> logData =
              logSnapshot.data() as Map<String, dynamic>;

          final String documentId = logSnapshot.id;
          final bool liked = logData['liked'] ?? false;
          final String milvusData = logData['milvusData'] ?? '';
          final String partitionName = logData['partitionName'] ?? '';

          final String prompt = logData['prompt'] ?? '';
          final String response = logData['response'] ?? '';
          final String timestampString = logData['timestamp'] as String;
          final DateTime dateTime = DateTime.parse(timestampString);
          final String formattedTimestamp =
              "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} " +
                  "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}";

          return GestureDetector(
            onTap: () => showLogDetails(logSnapshot),
            child: SizedBox(
              width: 300,
              child: ClipRect(
                child: OverflowBox(
                  alignment: Alignment.center,
                  child: Container(
                    margin: const EdgeInsets.all(8.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: const Color(0xff969d7b),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 130,
                        )
                      ],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Document ID: $documentId',
                            style: const TextStyle(color: Colors.white)),
                        Text('Prompt: $prompt',
                            style: const TextStyle(color: Colors.white),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        Text('Response: $response',
                            style: const TextStyle(color: Colors.white),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                        Text('Liked: $liked',
                            style: const TextStyle(color: Colors.white)),
                        Text('Milvus Data: $milvusData',
                            style: const TextStyle(color: Colors.white),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        Text('Partition Name: $partitionName',
                            style: const TextStyle(color: Colors.white)),
                        Text('Timestamp: $formattedTimestamp',
                            style: const TextStyle(color: Colors.white)),
                      ],
                    ),
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
