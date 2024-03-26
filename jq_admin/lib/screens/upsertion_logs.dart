import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jq_admin/widgets/backbutton.dart';
import 'package:jq_admin/widgets/palette.dart';
import 'package:number_paginator/number_paginator.dart';

class UpsertionLogsPage extends StatefulWidget {
  const UpsertionLogsPage({Key? key}) : super(key: key);

  @override
  State<UpsertionLogsPage> createState() => _UpsertionLogsPageState();
}

class _UpsertionLogsPageState extends State<UpsertionLogsPage> {
  late final Stream<QuerySnapshot> _logsStream;
  int _currentPage = 0;
  final int _logsPerPage = 10;
  late int _numberOfPages;
  List<DocumentSnapshot> _allLogs = [];
  List<DocumentSnapshot> _currentLogs = [];
  @override
  void initState() {
    super.initState();
    _logsStream =
        FirebaseFirestore.instance.collection('upsertionLogs').snapshots();
    _calculateNumberOfPages();
  }

  void _calculateNumberOfPages() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('upsertionLogs').get();
    int totalLogs = querySnapshot.docs.length;
    setState(() {
      _numberOfPages = (totalLogs / _logsPerPage).ceil();
    });
  }

  void _onPageSelected(int index) {
    setState(() {
      _currentPage = index; // Update the current page index
      // You may also need to update the logsToShow based on the new page index
      // For example, if you're using a paginated query to Firestore
      // you would adjust your query here.
    });
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
      backgroundColor: Palette.color5,
      appBar: AppBar(
        backgroundColor: Palette.color2,
        title: const Text(
          'Upsertion Logs',
          style: TextStyle(color: Palette.color4),
        ),
        leading: BackButtonWidget(color: Palette.color5),
        actions: [Image.asset("web/assets/jq.png")],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            padding: const EdgeInsets.all(24),
            width: MediaQuery.of(context).size.width * 0.95,
            height: MediaQuery.of(context).size.height *
                0.80, // e.g., 80% of the screen height
            decoration: BoxDecoration(
              color: Color(0xffccceB0), // Background color of the container
              borderRadius: BorderRadius.circular(10), // Rounded corners
              boxShadow: [
                BoxShadow(
                  color: Color.fromARGB(255, 112, 148, 117).withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: StreamBuilder<QuerySnapshot>(
              stream: _logsStream,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text("Loading");
                }
                int startIndex = _currentPage * _logsPerPage;
                int endIndex = startIndex + _logsPerPage;
                List<DocumentSnapshot> logsToShow;
                if (snapshot.data != null &&
                    snapshot.data!.docs.length > startIndex) {
                  endIndex = endIndex > snapshot.data!.docs.length
                      ? snapshot.data!.docs.length
                      : endIndex;
                  logsToShow =
                      snapshot.data!.docs.sublist(startIndex, endIndex);
                } else {
                  logsToShow = [];
                }

                return ListView.separated(
                  itemCount: snapshot.data?.docs.length ?? 0,
                  separatorBuilder: (context, index) => Divider(
                    color: Colors.grey[300],
                    thickness: 1,
                  ),
                  itemBuilder: (context, index) {
                    DocumentSnapshot documentSnapshot =
                        snapshot.data!.docs[index];
                    return _buildDocumentWidget(documentSnapshot);
                  },
                );
              },
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(15.0),
        child: NumberPaginator(
          numberPages: _numberOfPages,
          onPageChange: _onPageSelected,
          initialPage: _currentPage,
          showPrevButton: true,
          showNextButton: true,
          nextButtonContent: Icon(Icons.arrow_right_alt),
          prevButtonBuilder: (context) => TextButton(
            onPressed: _currentPage > 0
                ? () => _onPageSelected(_currentPage - 1)
                : null,
            child: const Row(
              children: [
                Icon(Icons.chevron_left),
                Text("Previous"),
              ],
            ),
          ),
          nextButtonBuilder: (context) => TextButton(
            onPressed: _currentPage < _numberOfPages - 1
                ? () => _onPageSelected(_currentPage + 1)
                : null,
            child: const Row(
              children: [
                Text("Next"),
                Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentWidget(DocumentSnapshot documentSnapshot) {
    Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;

    return Padding(
      padding: EdgeInsets.all(15.0),
      child: ListTile(
        title: Text(
          data.containsKey('title') ? data['title'] : 'No Title',
          style: TextStyle(color: Palette.color3),
        ),
        subtitle: Text(data.containsKey('date') ? data['date'] : 'No Date',
            style: TextStyle(color: Palette.color3)),
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
      ),
    );
  }
}
