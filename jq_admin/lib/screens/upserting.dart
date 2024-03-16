import 'package:flutter/material.dart';
import 'package:jq_admin/screens/schma_details.dart';
import '../widgets/backbutton.dart';

class UpsertingPage extends StatefulWidget {
  const UpsertingPage({super.key});

  @override
  _UpsertingPageState createState() => _UpsertingPageState();
}

class _UpsertingPageState extends State<UpsertingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffff1e4),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            const SizedBox(height: 50),
            const Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  children: [
                    BackButtonWidget(color: Color(0xfff2c87e)),
                    SizedBox(width: 50),
                  ],
                ),
                Text(
                  "Select a schema to upsert data",
                  style: TextStyle(
                    color: Color(0xff7a8066),
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildOptionContainer("Social Posts", Icons.chat),
                      _buildOptionContainer(
                          "Documents", Icons.insert_drive_file),
                      _buildOptionContainer("People", Icons.people),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionContainer(String schema, IconData iconData) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SchemaDetailsPage(schema: schema)),
      ),
      child: Container(
        width: 350,
        height: 500,
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: const Color(0xff969d7b), width: 5),
          borderRadius: BorderRadius.circular(25.0),
        ),
        child: Center(
          child: Icon(
            iconData,
            size: 100, // Adjust the size to fit your design
            color: Color(0xffE7D192), // Adjust the color to fit your design
          ),
        ),
      ),
    );
  }
}
