import 'package:flutter/material.dart';
import 'package:ebooking_desktop/pages/login.dart';
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginApp(),
    );
  }
}