import 'package:flutter/material.dart';
import 'package:jq_admin/screens/schma_details.dart';
import 'package:jq_admin/widgets/backbutton.dart';
import 'package:jq_admin/screens/upsertion_logs.dart';

import '../widgets/palette.dart';

class UpsertingPage extends StatefulWidget {
  const UpsertingPage({Key? key}) : super(key: key);

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
            // Header Row with Back Button, Title, and Logs Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Back button widget
                BackButtonWidget(color: const Color(0xfff2c87e)),
                // Page title
                const Expanded(
                  child: Text(
                    "Select a schema to upsert data",
                    style: TextStyle(
                      color: Color(0xff7a8066),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                // Logs button
                Container(
                  margin:
                      const EdgeInsets.all(8), // Adjust based on your layout
                  decoration: BoxDecoration(
                    color: Palette.color5, // Your light background color
                    shape: BoxShape.circle, // Circular shape
                    boxShadow: [
                      // Light source on top left; subtle light shadow
                      BoxShadow(
                        color:
                            Colors.white.withOpacity(0.8), // Light shadow color
                        offset: Offset(-4, -4),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                      // Simulated shadow on bottom right; slightly darker to enhance contrast
                      BoxShadow(
                        color: Colors.brown[100]!
                            .withOpacity(0.5), // Darker shadow for contrast
                        offset: Offset(4, 4),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Tooltip(
                    message: "View Upsertion Logs",
                    child: IconButton(
                      icon: Icon(
                        Icons.view_list,
                        color: Palette.color1,
                      ), // Icon with a darker color for visibility
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const UpsertionLogsPage()),
                        );
                      },
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 20),
            // Content
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildOptionContainer("Social Posts", Icons.chat),
                  _buildOptionContainer("Documents", Icons.insert_drive_file),
                  _buildOptionContainer("People", Icons.people),
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
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SchemaDetailsPage(schema: schema)),
        );
      },
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
            size: 100,
            color: const Color(0xffE7D192),
          ),
        ),
      ),
    );
  }
}
