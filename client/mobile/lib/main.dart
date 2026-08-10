import 'package:ebooking/providers/accommodation_provider.dart';
import 'package:ebooking/providers/feedback_provider.dart';
import 'package:ebooking/providers/location_provider.dart';
import 'package:ebooking/providers/message_provider.dart';
import 'package:ebooking/providers/profile_provider.dart';
import 'package:ebooking/providers/reservation_provider.dart';
import 'package:ebooking/providers/search_provider.dart';
import 'package:ebooking/providers/suggestion_provider.dart';
import 'package:ebooking/screens/partner_screens/partner_discover_screen.dart';
import 'package:ebooking/services/accommodation_service.dart';
import 'package:ebooking/services/auth_service.dart';
import 'package:ebooking/services/feedback_service.dart';
import 'package:ebooking/services/profile_service.dart';
import 'package:ebooking/services/reservation_service.dart';
import 'package:ebooking/services/search_service.dart';
import 'package:ebooking/services/signalr_service.dart';
import 'package:ebooking/services/suggestions_service.dart';
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
      ChangeNotifierProvider(
          create: (context) => AuthProvider(
              authService: AuthService(secureStorage: secureStorage))),
      ChangeNotifierProvider(
          create: (context) => ProfileProvider(
              profileService: ProfileService(secureStorage: secureStorage))),
      ChangeNotifierProvider(
          create: (context) => AccommodationProvider(
              accommodationService:
                  AccommodationService(secureStorage: secureStorage))),
      ChangeNotifierProvider(
          create: (context) => ReservationProvider(
              reservationService:
                  ReservationService(secureStorage: secureStorage))),
      ChangeNotifierProvider(
          create: (context) => MessageProvider(
              signalRService: SignalRService(secureStorage: secureStorage))),
      ChangeNotifierProvider(
          create: (context) => FeedbackProvider(
              feedbackService: FeedbackService(secureStorage: secureStorage))),
      ChangeNotifierProvider(
        create: (context) => SearchProvider(
            searchService: SearchService(secureStorage: secureStorage)),
      ),
      ChangeNotifierProvider(
        create: (context) =>
            SuggestionProvider(suggestionService: SuggestionsService()),
      ),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder(
        future: Future.wait([
          Provider.of<AuthProvider>(context, listen: false)
              .checkLoggedInStatus(),
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
              // Capture providers synchronously before the async chain
              final messageProvider =
                  Provider.of<MessageProvider>(context, listen: false);
              final profileProvider =
                  Provider.of<ProfileProvider>(context, listen: false);

              return FutureBuilder(
                future: messageProvider.startSignalR().then((_) =>
                    messageProvider.getChats().then((_) async {
                      for (var c in messageProvider.chats) {
                        await messageProvider.getMessages(c.id);
                        await messageProvider.addToChat(c.id);
                      }
                      await profileProvider.getProfile();
                    })),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  } else if (snapshot.hasError) {
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
                  child: Text(
                      'Location permission is required to use this app. Please enable it in settings.'),
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
