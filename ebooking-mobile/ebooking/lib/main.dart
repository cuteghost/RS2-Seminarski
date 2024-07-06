import 'package:ebooking/providers/accommodation_provider.dart';
import 'package:ebooking/providers/feedback_provider.dart';
import 'package:ebooking/providers/location_provider.dart';
import 'package:ebooking/providers/message_provider.dart';
import 'package:ebooking/providers/profile_provider.dart';
import 'package:ebooking/providers/reservation_provide.dart';
import 'package:ebooking/providers/search_provider.dart';
import 'package:ebooking/screens/partner_screens/partner_discover_screen.dart';
import 'package:ebooking/services/accommodation_service.dart';
import 'package:ebooking/services/auth_service.dart';
import 'package:ebooking/services/feedback_service.dart';
import 'package:ebooking/services/profile_service.dart';
import 'package:ebooking/services/reservation_service.dart';
import 'package:ebooking/services/search_service.dart';
import 'package:ebooking/services/signalr_service.dart';
import 'package:flutter/material.dart';
import 'package:ebooking/screens/login_screen.dart';
import 'package:ebooking/screens/customer_screens/discover_screen.dart';
import 'package:ebooking/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  final SecureStorage secureStorage = SecureStorage();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => LocationProvider()),
      ChangeNotifierProvider(create: (context) => AuthProvider(authService: AuthService(secureStorage: secureStorage))),
      ChangeNotifierProvider(create: (context) => ProfileProvider(profileService: ProfileService(secureStorage: secureStorage))),
      ChangeNotifierProvider(create: (context) => AccommodationProvider(accommodationService: AccommodationService(secureStorage: secureStorage))),
      ChangeNotifierProvider(create: (context) => ReservationProvider(reservationService: ReservationService(secureStorage: secureStorage))),
      ChangeNotifierProvider(create: (context) => MessageProvider(signalRService: SignalRService(secureStorage: secureStorage))),
      ChangeNotifierProvider(create: (context) => FeedbackProvider(feedbackService: FeedbackService(secureStorage: secureStorage))),
      ChangeNotifierProvider(create:(context) => SearchProvider(searchService: SearchService(secureStorage: secureStorage)),),
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
          _requestPermissions(),
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
          } else {
            final isLoggedIn = snapshot.data![0] as bool;
            final role = snapshot.data![1] as String;
            final permissionStatus = snapshot.data![2] as PermissionStatus;
            if (isLoggedIn && permissionStatus.isGranted) {
              return FutureBuilder(
                future: Future.wait([Provider.of<MessageProvider>(context, listen: false).startSignalR().then(
                        (_) => Provider.of<MessageProvider>(context, listen: false).getChats().then((_) async => {
                          for(var c in Provider.of<MessageProvider>(context, listen: false).chats){
                            await Provider.of<MessageProvider>(context, listen: false).getMessages(c.Id),
                            await Provider.of<MessageProvider>(context, listen: false).addToChat(c.Id)
                          },
                          await Provider.of<ProfileProvider>(context, listen: false).getProfile(),
                        })
                  )]), 
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    print (snapshot.error);
                    return const Scaffold(
                      body: Center(
                        child: Text('An error occurred'),
                      ),
                    );
                  } else {
                    if (role == "Customer") {
                      return DiscoverPropertiesPage();
                    } else {
                      return PartnerDiscoverPage();
                    }
                  }
                },
              );
            } else if (!permissionStatus.isGranted) {
              return const Scaffold(
                body: Center(
                  child: Text('Location permission is required to use this app. Please enable it in settings.'),
                ),
              );
            } else {
              return LoginPage();
            }
          }
        },
      ),
    );
  }

  Future<PermissionStatus> _requestPermissions() async {
    final status = await Permission.locationWhenInUse.request();
    if (status.isGranted || status.isLimited) {
      return status;
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
    return status;
  }
}
