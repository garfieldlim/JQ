import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LogsPage extends StatefulWidget {
  const LogsPage({super.key});

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
          return const Center(child: CircularProgressIndicator());
        }

        List<DocumentSnapshot> logs = snapshot.data!.docs;

        if (logs.isEmpty) {
          return const Center(child: Text('No data available.'));
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
                    margin: const EdgeInsets.all(8.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: const Color(0xffbec59a), // containers background color
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
                          log['text'] ?? '',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xff638a7e)),
                          maxLines: 3, // Adjust the number of lines as needed
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Document ID: $documentId',
                          style: const TextStyle(color: Color(0xffffe7a0)),
                        ),
                        if (!isUserMessage)
                          Text(
                            'Liked: ${log['liked'] ?? false}',
                            style: const TextStyle(color: Color(0xffffe7a0)),
                          ),
                        if (!isUserMessage)
                          Text(
                            'Disliked: ${log['disliked'] ?? false}',
                            style: const TextStyle(color: Color(0xffffe7a0)),
                          ),
                        Text(
                          'Is User Message: $isUserMessage',
                          style: const TextStyle(color: Color(0xffffe7a0)),
                        ),
                        Text(
                          'Partition Name: $partitionName',
                          style: const TextStyle(color: Color(0xffffe7a0)),
                        ),
                        Text(
                          'Milvus Data: $milvusData',
                          style: const TextStyle(color: Color(0xffffe7a0)),
                        ),
                        Text(
                          'Timestamp: $formattedTimestamp',
                          style: const TextStyle(color: Color(0xffffe7a0)),
                        ),
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
      backgroundColor: const Color(0xffaebb9f),
      body: ListView(
        children: [
          const SizedBox(height: 15),
          const Padding(
            padding: EdgeInsets.all(10.0),
            child: Text('Logs',
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                )),
          ),
          // Recently Added Section
          const SizedBox(height: 15),
          const Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              "Recently Added",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
          SizedBox(
              height: 300, child: _buildHorizontalLogList(sortByTime: true)),
          const SizedBox(height: 25),
          // Most Liked Section
          const Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              "Most Liked",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(
              height: 300, child: _buildHorizontalLogList(sortByTime: false)),
        ],
      ),
    );
  }
}
