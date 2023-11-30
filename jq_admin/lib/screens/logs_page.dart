import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/log_list_widget.dart';
import 'Logsdetail.dart';

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

  void navigateToLogDetails(DocumentSnapshot logSnapshot) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => LogDetailsPage(logSnapshot: logSnapshot),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffff1e4),
      body: ListView(
        children: [
          const SizedBox(height: 15),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Image.asset(
                  'web/assets/jq.png',
                  height: 150,
                ),
              ),
            ),
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
                  color: Color(0xff7a8066)),
            ),
          ),
          SizedBox(
            height: 300,
            child: buildHorizontalLogList(
                logsStream: logsStream,
                sortByTime: true,
                sortByLikes: false,
                sortByDislikes: false,
                showLogDetails: navigateToLogDetails),
          ),
          const SizedBox(height: 25),
          // Most Liked Section
          const Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              "Most Liked",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xff7a8066),
              ),
            ),
          ),
          SizedBox(
            height: 300,
            child: buildHorizontalLogList(
                logsStream: logsStream,
                sortByTime: false,
                sortByLikes: true,
                sortByDislikes: false,
                showLogDetails: navigateToLogDetails),
          ),
          const Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              "Most Disliked",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xff7a8066),
              ),
            ),
          ),
          SizedBox(
            height: 300,
            child: buildHorizontalLogList(
                logsStream: logsStream,
                sortByTime: false,
                sortByLikes: false,
                sortByDislikes: true,
                showLogDetails: navigateToLogDetails),
          ),
        ],
      ),
    );
  }
}
