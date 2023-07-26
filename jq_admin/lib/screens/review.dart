import 'package:flutter/material.dart';
import 'package:jq_admin/screens/homepage.dart';

class ReviewPage extends StatefulWidget {
  final String schema;
  final String? data; // data can now be nullable

  ReviewPage(
      {required this.schema,
      this.data, // remove 'required' keyword here
      Key? key,
      required String filePath})
      : super(key: key);

  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  late TextEditingController
      _dataController; // declare the controller without initializing

  @override
  void initState() {
    super.initState();
    // only initialize the controller if widget.data is not null
    if (widget.data != null) {
      _dataController = TextEditingController(text: widget.data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        width: 1500,
        decoration: BoxDecoration(
          image: DecorationImage(
            image:
                NetworkImage("assets/bg.png"), // Replace with your image file
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Schema: ${widget.schema}'),
              SizedBox(height: 20),
              // only create the TextField if widget.data is not null
              if (widget.data != null)
                TextField(
                  controller: _dataController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Data',
                  ),
                ),
              SizedBox(height: 35),
              Center(
                child: ElevatedButton(
                  child: const Text(
                    'Upsert',
                    style: TextStyle(fontSize: 18),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UpsertingPage()),
                    );
                    print('Schema: ${widget.schema}');
                    print('Data: ${_dataController.text}');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
