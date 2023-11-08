import 'package:flutter/material.dart';
import 'package:jq_admin/screens/upserting.dart';

import '../widgets/nav.dart';
import 'logs_page.dart';

class Admin_dashboard extends StatelessWidget {
  const Admin_dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffaebb9f),
      body: Row(
        children: [
          Container(
            width: 70, // Width of the left nav bar
            margin: EdgeInsets.only(right: 34),
            decoration: BoxDecoration(
              color: Color(0xff719382), // Background color
              borderRadius: BorderRadius.circular(15), // Rounded corners
            ),
            child: Column(
              children: [
                NavItem(
                  iconData: Icons.home,
                  color: Color(0xffe7d192),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Admin_dashboard()),
                    );
                  },
                  labelText: 'Logs',
                ),
                NavItem(
                  iconData: Icons.upload_file,
                  color: Color(0xffe7d192),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UpsertingPage()),
                    );
                  },
                  labelText: 'Upserting',
                ),
                NavItem(
                  iconData: Icons.menu_book,
                  color: Color(0xffe7d192),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Admin_dashboard()),
                    );
                  },
                  labelText: 'Knowlege base logs',
                ),
                Expanded(
                  child: Container(
                    alignment: Alignment.bottomCenter,
                    child: NavItem(
                      iconData: Icons.logout,
                      onPressed: () {
                        print("Logout icon pressed");
                      },
                      color: Color(0xffe7d192),
                      labelText: 'Logout',
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Main content
          Expanded(
            child: Center(
              child: LogsPage(),
            ),
          ),
        ],
      ),
    );
  }
}
