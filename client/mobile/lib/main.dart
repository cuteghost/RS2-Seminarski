import 'package:ebooking/config/app_constants.dart';
import 'package:ebooking/config/app_theme.dart';
import 'package:ebooking/providers/accommodation_provider.dart';
import 'package:ebooking/providers/feedback_provider.dart';
import 'package:ebooking/providers/location_provider.dart';
import 'package:ebooking/providers/message_provider.dart';
import 'package:ebooking/providers/catalog_provider.dart';
import 'package:ebooking/providers/payment_provider.dart';
import 'package:ebooking/providers/profile_provider.dart';
import 'package:ebooking/providers/reservation_provider.dart';
import 'package:ebooking/providers/search_provider.dart';
import 'package:ebooking/providers/suggestion_provider.dart';
import 'package:ebooking/screens/partner_screens/my_accommodations_screen.dart';
import 'package:ebooking/services/accommodation_service.dart';
import 'package:ebooking/services/api_client.dart';
import 'package:ebooking/services/auth_service.dart';
import 'package:ebooking/services/feedback_service.dart';
import 'package:ebooking/services/location_service.dart';
import 'package:ebooking/services/catalog_service.dart';
import 'package:ebooking/services/payment_service.dart';
import 'package:ebooking/services/profile_service.dart';
import 'package:ebooking/services/reservation_service.dart';
import 'package:ebooking/services/search_service.dart';
import 'package:ebooking/services/secure_storage.dart';
import 'package:ebooking/services/signalr_service.dart';
import 'package:ebooking/services/suggestions_service.dart';
import 'package:ebooking/utils/navigation_utils.dart';
import 'package:ebooking/utils/session_utils.dart';
import 'package:flutter/material.dart';
import 'package:ebooking/screens/login_screen.dart';
import 'package:ebooking/screens/customer_screens/discover_screen.dart';
import 'package:ebooking/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  final SecureStorage secureStorage = SecureStorage();

  // One client for every service: it adds the bearer token, unwraps
  // { message, data }, walks pages, and is the single place that reacts to
  // a 401 by clearing the token and sending the user back to sign in.
  final ApiClient apiClient = ApiClient(secureStorage: secureStorage)
    ..onUnauthorized = handleUnauthorized;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => LocationProvider(
            locationService: LocationService(apiClient: apiClient),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => AuthProvider(
            authService: AuthService(
              apiClient: apiClient,
              secureStorage: secureStorage,
            ),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => ProfileProvider(
            profileService: ProfileService(
              apiClient: apiClient,
              secureStorage: secureStorage,
            ),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => AccommodationProvider(
            accommodationService: AccommodationService(apiClient: apiClient),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => ReservationProvider(
            reservationService: ReservationService(apiClient: apiClient),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => CatalogProvider(
            catalogService: CatalogService(apiClient: apiClient),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => PaymentProvider(
            paymentService: PaymentService(apiClient: apiClient),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => MessageProvider(
            signalRService: SignalRService(secureStorage: secureStorage),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => FeedbackProvider(
            feedbackService: FeedbackService(apiClient: apiClient),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => SearchProvider(
            searchService: SearchService(apiClient: apiClient),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => SuggestionProvider(
            suggestionService: SuggestionsService(apiClient: apiClient),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // The api client reaches the navigator through this key when a request
      // comes back 401, which is the one case with no BuildContext at hand.
      navigatorKey: appNavigatorKey,
      theme: AppTheme.dark,
      home: FutureBuilder(
        future: Future.wait([
          Provider.of<AuthProvider>(
            context,
            listen: false,
          ).checkLoggedInStatus(),
          Provider.of<AuthProvider>(context, listen: false).roleCheck(),
          _requestPermissions(),
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasError) {
            return const Scaffold(
              body: Center(child: Text('An error occurred')),
            );
          } else {
            final isLoggedIn = snapshot.data![0] as bool;
            final role = snapshot.data![1] as String;
            final permissionStatus = snapshot.data![2] as PermissionStatus;
            if (isLoggedIn && permissionStatus.isGranted) {
              // Capture providers synchronously before the async chain
              final messageProvider = Provider.of<MessageProvider>(
                context,
                listen: false,
              );
              final profileProvider = Provider.of<ProfileProvider>(
                context,
                listen: false,
              );

              return FutureBuilder(
                // The profile is a plain HTTP call and shares nothing with
                // the hub, so it no longer waits behind the whole SignalR
                // chain before the first screen can be built.
                future: Future.wait<void>([
                  messageProvider.loadInitialState(),
                  if (role != Roles.partner) profileProvider.getProfile(),
                ]),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  } else if (snapshot.hasError) {
                    // ApiException.toString() is the server's own message,
                    // which says more than 'An error occurred' did.
                    return Scaffold(
                      body: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            '${snapshot.error}',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  } else {
                    if (role == Roles.partner) {
                      return const MyAccommodationsScreen();
                    } else {
                      return DiscoverPropertiesPage();
                    }
                  }
                },
              );
            } else if (!permissionStatus.isGranted) {
              return const Scaffold(
                body: Center(
                  child: Text(
                    'Location permission is required to use this app. Please enable it in settings.',
                  ),
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
