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

  void _showEditDialog(DocumentSnapshot documentSnapshot) {
    Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
    final _formKey = GlobalKey<FormState>();
    Map<String, TextEditingController> controllers = {};

    // Initialize text controllers with current data
    data.forEach((key, value) {
      controllers[key] = TextEditingController(text: value.toString());
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Document'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List<Widget>.generate(data.keys.length, (index) {
                  String key = data.keys.elementAt(index);
                  return TextFormField(
                    controller: controllers[key],
                    decoration: InputDecoration(labelText: key),
                  );
                }),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Update'),
              onPressed: () {
                Map<String, dynamic> updatedData = {};
                controllers.forEach((key, controller) {
                  updatedData[key] = controller.text;
                });
                documentSnapshot.reference.update(updatedData).then((_) {
                  Navigator.of(context).pop();
                });
              },
            ),
          ],
        );
      },
    );
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

    return ListTile(
      title: Text(data.containsKey('title') ? data['title'] : 'No Title'),
      subtitle: Text(data.containsKey('date') ? data['date'] : 'No Date'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => _showEditDialog(documentSnapshot),
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => documentSnapshot.reference.delete(),
          ),
        ],
      ),
    );
  }
}
