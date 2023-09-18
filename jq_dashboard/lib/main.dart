import 'package:flutter/material.dart';
// importing admin_menu.dart from screens folder
import 'package:jq_dashboard/screens/admin_menu.dart';
import 'package:jq_dashboard/screens/table.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flask Integration',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 255, 223, 107)),
        useMaterial3: true,
      ),
      home: DataTableDemo(),
      debugShowCheckedModeBanner: false,
    );
  }
}
