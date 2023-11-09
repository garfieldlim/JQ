import 'package:flutter/material.dart';
import 'package:jq_admin/screens/upserting.dart';

import '../widgets/nav.dart';
import 'logs_page.dart';
import 'table.dart';

class Admin_dashboard extends StatelessWidget {
  const Admin_dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffaebb9f),
      body: Row(
        children: [
          Container(
            width: 70, // Width of the left nav bar
            margin: const EdgeInsets.only(right: 34),
            decoration: BoxDecoration(
              color: const Color(0xff719382), // Background color
              borderRadius: BorderRadius.circular(15), // Rounded corners
            ),
            child: Column(
              children: [
                NavItem(
                  iconData: Icons.home,
                  color: const Color(0xffe7d192),
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
                  color: const Color(0xffe7d192),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const UpsertingPage()),
                    );
                  },
                  labelText: 'Upserting',
                ),
                NavItem(
                  iconData: Icons.menu_book,
                  color: const Color(0xffe7d192),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DataTableDemo()),
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
                      color: const Color(0xffe7d192),
                      labelText: 'Logout',
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Main content
          const Expanded(
            child: Center(
              child: LogsPage(),
            ),
          ),
        ],
      ),
    );
  }
}
