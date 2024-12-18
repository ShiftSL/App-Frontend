import 'package:flutter/material.dart';
import 'widgets/bottom_nav_bar.dart';

void main() {
  runApp(const ShiftSLApp());
}

class ShiftSLApp extends StatelessWidget {
  const ShiftSLApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ShiftSL',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const BottomNavBar(),
    );
  }
}
