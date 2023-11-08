import 'package:flutter/material.dart';
// importing admin_menu.dart from screens folder
import 'package:jq_dashboard/screens/table.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flask Integration',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 255, 223, 107)),
        useMaterial3: true,
      ),
      home: const DataTableDemo(),
      debugShowCheckedModeBanner: false,
    );
  }
}
