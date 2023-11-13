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

        List<DocumentSnapshot> logs = snapshot.data!.docs;

        if (logs.isEmpty) {
          return const Center(child: Text('No data available.'));
        }

        if (sortByTime) {
          logs.sort((a, b) {
            final Timestamp? aTimestamp = a.get('timestamp') as Timestamp?;
            final Timestamp? bTimestamp = b.get('timestamp') as Timestamp?;
            if (aTimestamp != null && bTimestamp != null) {
              return bTimestamp.toDate().compareTo(aTimestamp.toDate());
            } else {
              return 0;
            }
          });
        } else if (sortByLikes) {
          logs.sort((a, b) {
            final bool aLiked =
                (a.data() as Map<String, dynamic>)['liked'] as bool? ?? false;
            final bool bLiked =
                (b.data() as Map<String, dynamic>)['liked'] as bool? ?? false;
            return aLiked == bLiked ? 0 : (aLiked ? -1 : 1);
          });
        } else if (sortByDislikes) {
          logs.sort((a, b) {
            final bool aDisliked =
                (a.data() as Map<String, dynamic>)['disliked'] as bool? ??
                    false;
            final bool bDisliked =
                (b.data() as Map<String, dynamic>)['disliked'] as bool? ??
                    false;
            return aDisliked == bDisliked ? 0 : (aDisliked ? 1 : -1);
          });
        }

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: logs.length,
          itemBuilder: (context, index) {
            final DocumentSnapshot logSnapshot = logs[index];
            final Map<String, dynamic> logData =
                logSnapshot.data() as Map<String, dynamic>;
            final documentId = logSnapshot.id;
            final isUserMessage = logData['isUserMessage'] ?? false;
            final partitionName = logData['partitionName'] ?? '';
            final milvusData = logData['milvusData'] ?? '';

            final timestamp = logData['timestamp'] != null
                ? (logData['timestamp'] as Timestamp).toDate()
                : DateTime.now();

            final formattedTimestamp =
                '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}';

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
                        color: const Color(
                            0xff969d7b), // Container's background color
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
                          Text(
                            logData['text'] ?? '',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Document ID: $documentId',
                            style: const TextStyle(color: Color(0xffFFFFFF)),
                          ),
                          if (!isUserMessage)
                            Text(
                              'Liked: ${logData['liked'] ?? false}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          if (!isUserMessage)
                            Text(
                              'Disliked: ${logData['disliked'] ?? false}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          Text(
                            'Is User Message: $isUserMessage',
                            style: const TextStyle(color: Colors.white),
                          ),
                          Text(
                            'Partition Name: $partitionName',
                            style: const TextStyle(color: Colors.white),
                          ),
                          Text(
                            'Milvus Data: ${logData['milvusData'] ?? ''}',
                            style: const TextStyle(color: Colors.white),
                            maxLines:
                                1, // Restrict to a single line or more depending on your layout
                            overflow: TextOverflow
                                .ellipsis, // Use ellipsis to indicate text overflow
                          ),
                          Text(
                            'Timestamp: $formattedTimestamp',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      });
}
