import 'package:flutter/material.dart';

import '../widgets/nav.dart';

class Admin_dashboard extends StatelessWidget {
  const Admin_dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Left navigation bar
          Container(
            width: 70, // Width of the left nav bar
            margin: EdgeInsets.only(top: 20, left: 20, bottom: 20),

            decoration: BoxDecoration(
              color: Color(0xffaebb9f), // Background color
              borderRadius: BorderRadius.circular(20), // Rounded corners
            ),
            child: Column(
              children: [
                NavItem(
                  iconData: Icons.home,
                  color: Color(0xffe7d192),
                  onPressed: () {
                    print("Home icon pressed");
                  },
                ),
                NavItem(
                  iconData: Icons.upload_file,
                  color: Color(0xffe7d192),
                  onPressed: () {
                    print("Settings icon pressed");
                  },
                ),
                NavItem(
                  iconData: Icons.menu_book,
                  color: Color(0xffe7d192),
                  onPressed: () {
                    print("Settings icon pressed");
                  },
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
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Main content
          Expanded(
            child: Center(
              child: Text('LOGS'),
            ),
          ),
        ],
      ),
    );
  }
}
