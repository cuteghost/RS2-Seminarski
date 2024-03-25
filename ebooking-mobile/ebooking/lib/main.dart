import 'package:ebooking/screens/discover_screen.dart';
import 'package:flutter/material.dart';
import 'package:ebooking/screens/login_screen.dart';
import 'package:ebooking/services/auth_service.dart';
import 'package:ebooking/providers/auth_provider.dart';
import 'package:provider/provider.dart';
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: MaterialApp(
        home: LoginPage(), // Your initial page
      ),
    );
  }
}