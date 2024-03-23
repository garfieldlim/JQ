import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpsertionLogsPage extends StatefulWidget {
  const UpsertionLogsPage({Key? key}) : super(key: key);

  @override
  State<UpsertionLogsPage> createState() => _UpsertionLogsPageState();
}

class _UpsertionLogsPageState extends State<UpsertionLogsPage> {
  late final Stream<QuerySnapshot> _logsStream;

  @override
  void initState() {
    super.initState();
    _logsStream =
        FirebaseFirestore.instance.collection('upsertionLogs').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upsertion Logs'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _logsStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Loading");
          }

          return ListView.builder(
            itemCount: snapshot.data?.docs.length ?? 0,
            itemBuilder: (context, index) {
              DocumentSnapshot documentSnapshot = snapshot.data!.docs[index];
              return _buildDocumentWidget(documentSnapshot);
            },
          );
        },
      ),
    );
  }

  Widget _buildDocumentWidget(DocumentSnapshot documentSnapshot) {
    Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;

    return ExpansionTile(
      title: Text(data.containsKey('title') ? data['title'] : 'No Title'),
      subtitle: Text(data.containsKey('date') ? data['date'] : 'No Date'),
      children: data.entries.map<Widget>((entry) {
        return ListTile(
          title: Text(entry.key),
          subtitle: Text(entry.value.toString()),
        );
      }).toList(),
    );
  }
}
