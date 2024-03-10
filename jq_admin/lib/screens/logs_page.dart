import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/log_list_widget.dart';
import 'Logsdetail.dart';
import 'logsDetailList.dart';
import '../widgets/buildSearch.dart';

class LogsPage extends StatefulWidget {
  const LogsPage({
    super.key,
  });

  @override
  _LogsPageState createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> {
  late CollectionReference logsCollection;
  late Stream<QuerySnapshot> logsStream;
  List<Map<String, dynamic>> allLogs = [];
  List<Map<String, dynamic>> filteredLogs = [];
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";
  String selectedField = 'id';

  @override
  void initState() {
    super.initState();
    logsCollection = FirebaseFirestore.instance.collection('chat_messages');
    logsStream = logsCollection.snapshots();
    fetchAllLogs();
  }

  void fetchAllLogs() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('chat_messages').get();
    setState(() {
      allLogs = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      filteredLogs =
          List.from(allLogs); // Initially, filteredLogs shows all logs
    });
  }

  void filterLogs(String searchField, String searchQuery) {
    setState(() {
      if (searchQuery.isEmpty) {
        filteredLogs = List.from(allLogs);
      } else {
        filteredLogs = allLogs.where((log) {
          var fieldValue = (log[searchField] ?? '').toString().toLowerCase();
          return fieldValue.contains(searchQuery.toLowerCase());
        }).toList();
      }
    });
  }

  void navigateToLogDetails(DocumentSnapshot logSnapshot) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => LogDetailsPage(logSnapshot: logSnapshot),
    ));
  }

  void navigateToLogDetailsList(Map<String, dynamic> logData) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => LogDetailsPageList(logData: logData),
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
            padding: const EdgeInsets.all(10.0),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Image.asset(
                  'web/assets/jq.png',
                  height: 150,
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          const Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              "Search Results",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff7a8066)),
            ),
          ),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search logs',
              suffixIcon: IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  setState(() {
                    searchQuery = _searchController.text;
                    filterLogs(selectedField, searchQuery);
                  });
                },
              ),
            ),
            textAlign: TextAlign.center,
          ),
          Center(
            child: DropdownButton<String>(
              value: selectedField,
              onChanged: (String? newValue) {
                setState(() {
                  selectedField = newValue!;
                });
              },
              items: <String>[
                'id',
                'milvusData',
                'partitionName',
                'prompt',
                'response',
                'timestamp'
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          if (_searchController.text.isEmpty)
            Center(child: Text('Enter search.')) // When search bar is empty
          else if (filteredLogs.isEmpty)
            Center(
                child: Text('Data not found.')) // When search yields no results
          else
            SizedBox(
              height: 300,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: filteredLogs.length, // Use filteredLogs list
                itemBuilder: (context, index) {
                  final log = filteredLogs[index];
                  return GestureDetector(
                    onTap: () =>
                        navigateToLogDetailsList(log), // Adjust this as needed
                    child: SizedBox(
                      width: 300,
                      child: LogItemWidget(log: log),
                    ),
                  );
                },
              ),
            ),
          // Recently Added Section
          const SizedBox(height: 25),
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
