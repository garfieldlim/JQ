import 'package:flutter/material.dart';
import 'package:jq_admin/screens/upserting.dart';

import '../widgets/nav.dart';
import 'logs_page.dart';
import 'table.dart';

class Admin_dashboard extends StatefulWidget {
  const Admin_dashboard({super.key});

  @override
  State<Admin_dashboard> createState() => _Admin_dashboardState();
}

class _Admin_dashboardState extends State<Admin_dashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffff1e4),
      body: Row(
        children: [
          Container(
            width:
                70, // Adjust this width to fit your nav items and search field
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      // Your NavItems go here...
                      NavItem(
                        iconData: Icons.home,
                        color: const Color(0xff969d7b),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Admin_dashboard()),
                          );
                        },
                        labelText: 'Logs',
                      ),
                      NavItem(
                        iconData: Icons.upload_file,
                        color: const Color(0xff969d7b),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const UpsertingPage()),
                          );
                        },
                        labelText: 'Upserting',
                      ),
                      NavItem(
                        iconData: Icons.menu_book,
                        color: const Color(0xff969d7b),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const DataTableDemo()),
                          );
                        },
                        labelText: 'Knowlege base logs',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Main content
          Expanded(
            flex: 5, // Adjust flex to give more space to the main content
            child: Center(
              child: LogsPage(),
            ),
          ),
        ],
      ),
    );
  }
}
