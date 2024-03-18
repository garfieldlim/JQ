import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jq_admin/screens/upserting.dart';

import '../widgets/nav.dart';
import 'login.dart';
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
          SizedBox(
            width: 70,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0XFFF2C87E),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      children: [
                        NavItem(
                          iconData: Icons.home,
                          color: const Color(0xff969d7b),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const Admin_dashboard()),
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
                        Spacer(),
                        NavItem(
                          iconData: Icons.logout,
                          color: Color(0xff969d7b),
                          onPressed: () {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) => LoginPage()),
                              (Route<dynamic> route) => false,
                            );
                          },
                          labelText: 'Logout',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Expanded(
            flex: 5,
            child: Center(
              child: LogsPage(),
            ),
          ),
        ],
      ),
    );
  }
}
