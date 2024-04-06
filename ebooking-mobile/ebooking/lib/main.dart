import 'package:flutter/material.dart';
import 'package:ebooking/screens/login_screen.dart';
import 'package:ebooking/screens/discover_screen.dart';
import 'package:ebooking/providers/auth_provider.dart';
import 'package:provider/provider.dart';

void main() {
  final authProvider = AuthProvider();
  
  runApp(MyApp(authProvider: authProvider));
  }

class MyApp extends StatelessWidget {
  final AuthProvider authProvider;

  MyApp({required this.authProvider});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthProvider>.value(
      value: authProvider,
      child: MaterialApp(
        home: FutureBuilder(
          future: authProvider.checkLoggedInStatus(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              // Check if user is logged in or not
              if (snapshot.data == true) {
                // If logged in, navigate to DiscoverScreen
                return DiscoverPropertiesPage();
              } else {
                // If not logged in, navigate to LoginPage
                return LoginPage();
              }
            } else {
              // While checking the login status, show a loading spinner
              return Scaffold(body: const Center(child: const CircularProgressIndicator()));
            }
          },
        ),
      ),
    );
  }
}