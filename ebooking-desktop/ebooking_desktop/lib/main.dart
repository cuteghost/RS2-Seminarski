import 'package:ebooking_desktop/providers/admin_provider.dart';
import 'package:ebooking_desktop/services/admin_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ebooking_desktop/pages/dashboard.dart';
import 'package:ebooking_desktop/providers/auth_provider.dart';
import 'package:ebooking_desktop/providers/message_provider.dart';
import 'package:ebooking_desktop/providers/profile_provider.dart';
import 'package:ebooking_desktop/services/auth_service.dart';
import 'package:ebooking_desktop/services/profile_service.dart';
import 'package:ebooking_desktop/services/signalr_service.dart';
import 'package:ebooking_desktop/pages/login.dart';

void main() {
  final SecureStorage secureStorage = SecureStorage();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => AuthProvider(authService: AuthService(secureStorage: secureStorage))),
      ChangeNotifierProvider(create: (context) => ProfileProvider(profileService: ProfileService(secureStorage: secureStorage))),
      ChangeNotifierProvider(create: (context) => MessageProvider(signalRService: SignalRService(secureStorage: secureStorage))),
      ChangeNotifierProvider(create: (context) => AdminProvider(adminService: AdminService(secureStorage: secureStorage))),
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
        future: Future.wait([
          Provider.of<AuthProvider>(context, listen: false).checkLoggedInStatus(),
          Provider.of<AuthProvider>(context, listen: false).roleCheck(),
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (snapshot.hasError) {
            print (snapshot.error);
            
            return const Scaffold(
              body: Center(
                child: Text('An error occurred'),
              ),
            );
          } 
          else {
            final isLoggedIn = snapshot.data![0] as bool;
            final role = snapshot.data![1] as String;
            
            if (isLoggedIn && role == 'Administrator') {
              return FutureBuilder(
                future: Future.wait([Provider.of<MessageProvider>(context, listen: false).startSignalR().then(
                        (_) => Provider.of<MessageProvider>(context, listen: false).getChats().then((_) async => {
                          for(var c in Provider.of<MessageProvider>(context, listen: false).chats) {
                            await Provider.of<MessageProvider>(context, listen: false).getMessages(c.Id),
                            await Provider.of<MessageProvider>(context, listen: false).addToChat(c.Id),
                          },
                          await Provider.of<ProfileProvider>(context, listen: false).getProfile(),
                          await Provider.of<AdminProvider>(context, listen: false).getAccommodations(),
                          await Provider.of<AdminProvider>(context, listen: false).getProfiles(),
                          await Provider.of<AdminProvider>(context, listen: false).getReservations(),
                        }),
                )]), 
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    print(snapshot.error);
                    return const Scaffold(
                      body: Center(
                        child: Text('An error occurred'),
                      ),
                    );
                  } else {
                    return DashboardApp();
                  }
                },
              );
            } else {
              return LoginPage();
            }
          }
        },
      ), 
    );
  }
}