import 'package:ebooking/providers/accommodation_provider.dart';
import 'package:ebooking/providers/location_provider.dart';
import 'package:ebooking/providers/profile_provider.dart';
import 'package:ebooking/services/accommodation_service.dart';
import 'package:ebooking/services/auth_service.dart';
import 'package:ebooking/services/profile_service.dart';
import 'package:flutter/material.dart';
import 'package:ebooking/screens/login_screen.dart';
import 'package:ebooking/screens/customer_screens/discover_screen.dart';
import 'package:ebooking/providers/auth_provider.dart';
import 'package:provider/provider.dart';

void main() {
  final SecureStorage secureStorage = SecureStorage();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => LocationProvider()),
      ChangeNotifierProvider(create: (context) => AuthProvider(authService: AuthService(secureStorage: secureStorage)),),
      ChangeNotifierProvider(create: (context) => ProfileProvider(profileService: ProfileService(secureStorage: secureStorage))),
      ChangeNotifierProvider(create: (context) => AccommodationProvider(accommodationService: AccommodationService(secureStorage: secureStorage))),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  MyApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder(
        future: Provider.of<AuthProvider>(context, listen: false).checkLoggedInStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          return snapshot.data == true ? DiscoverPropertiesPage() : LoginPage();
        },
        ),
        );
  }
}
