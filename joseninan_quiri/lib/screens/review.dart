import 'package:flutter/material.dart';
import 'package:josenian_quiri/screens/query.dart';

class ReviewPage extends StatefulWidget {
  final String schema;
  final String data;

  ReviewPage(
      {required this.schema,
      required this.data,
      Key? key,
      required String filePath})
      : super(key: key);

  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  TextEditingController _dataController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dataController.text = widget.data;
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
                      MaterialPageRoute(builder: (context) => HomePage()),
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
