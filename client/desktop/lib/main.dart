import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ebooking_desktop/config/app_theme.dart';
import 'package:ebooking_desktop/pages/login.dart';
import 'package:ebooking_desktop/providers/admin_provider.dart';
import 'package:ebooking_desktop/providers/auth_provider.dart';
import 'package:ebooking_desktop/providers/location_provider.dart';
import 'package:ebooking_desktop/providers/message_provider.dart';
import 'package:ebooking_desktop/providers/profile_provider.dart';
import 'package:ebooking_desktop/services/admin_service.dart';
import 'package:ebooking_desktop/services/auth_service.dart';
import 'package:ebooking_desktop/services/location_service.dart';
import 'package:ebooking_desktop/services/profile_service.dart';
import 'package:ebooking_desktop/services/signalr_service.dart';
import 'package:ebooking_desktop/widgets/app_shell.dart';
import 'package:ebooking_desktop/widgets/nocturne.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Jedan `SecureStorage` za sve servise — dijele isti token.
  final secureStorage = SecureStorage();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            authService: AuthService(secureStorage: secureStorage),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(
            profileService: ProfileService(secureStorage: secureStorage),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => MessageProvider(
            signalRService: SignalRService(secureStorage: secureStorage),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => AdminProvider(
            adminService: AdminService(secureStorage: secureStorage),
          ),
        ),
        // NOVO — desktop ranije nije imao provider za lokacije; ekran država
        // je zvao statički HTTP servis direktno iz widgeta.
        ChangeNotifierProvider(
          create: (_) => LocationProvider(
            locationService: LocationService(secureStorage: secureStorage),
          ),
        ),
      ],
      child: const EBookingAdminApp(),
    ),
  );
}

class EBookingAdminApp extends StatelessWidget {
  const EBookingAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'eBooking — Administracija',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const _Bootstrap(),
    );
  }
}

/// Odlučuje da li se prikazuje prijava ili glavni okvir.
///
/// PREPISANO. Stari `main.dart` je imao dva ugniježđena `FutureBuilder`-a,
/// gdje je unutrašnji pokretao lanac od pet uzastopnih mrežnih poziva
/// direktno u `future:` argumentu. Tri problema:
///
///  1. `future:` se evaluira pri SVAKOM `build()`-u, pa je svaki rebuild
///     (npr. promjena veličine prozora) ponovo pokretao cijeli lanac
///     mrežnih poziva.
///  2. `snapshot.data![0] as bool` bi bacio na `null` da je `Future.wait`
///     ikad vratio grešku.
///  3. Ista bootstrap logika je bila duplirana u `login.dart`
///     (Upute 8.1 — DRY, iste stvari ne držati na dva mjesta).
///
/// Sada: `StatefulWidget` koji lanac pokreće JEDNOM u `initState`.
class _Bootstrap extends StatefulWidget {
  const _Bootstrap();

  @override
  State<_Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends State<_Bootstrap> {
  late Future<bool> _startup;

  @override
  void initState() {
    super.initState();
    _startup = _restoreSession();
  }

  /// Vraća `true` ako je sesija validna i pripadа administratoru.
  Future<bool> _restoreSession() async {
    final auth = context.read<AuthProvider>();

    final loggedIn = await auth.checkLoggedInStatus();
    if (!loggedIn) return false;

    final role = await auth.roleCheck();
    if (role != 'Administrator') {
      await auth.logout();
      return false;
    }

    if (!mounted) return false;
    final profile = context.read<ProfileProvider>();
    final admin = context.read<AdminProvider>();
    final locations = context.read<LocationProvider>();
    final messages = context.read<MessageProvider>();

    // Podaci se povlače paralelno. `AdminProvider.loadAll` i
    // `LocationProvider.loadAll` interno hvataju greške i izlažu ih kroz
    // `error` polje, pa jedan pali servis ne obara cijeli start.
    await Future.wait([
      profile.getProfile(),
      admin.loadAll(),
      locations.loadAll(),
    ]);

    // Messenger namjerno nije u `Future.wait` — ako Messenger mikroservis
    // nije podignut, aplikacija se i dalje mora otvoriti.
    messages.bootstrap();

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _startup,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: NLoading(label: 'Pokretanje aplikacije…')),
          );
        }

        // Greška pri obnovi sesije nije razlog za "An error occurred" ekran
        // bez izlaza (tako je bilo ranije) — korisnika vodimo na prijavu.
        if (snapshot.hasError || snapshot.data != true) {
          return const LoginPage();
        }

        return const AppShell();
      },
    );
  }
}
