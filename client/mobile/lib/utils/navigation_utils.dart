import 'package:ebooking/screens/login_screen.dart';
import 'package:flutter/material.dart';

/// Bottom-nav-bar style navigation: replaces the current screen instead of
/// pushing a new one onto the stack. This keeps the back stack flat so the
/// user only needs one back-press to leave the tabbed section, regardless of
/// how many times they've switched tabs (Messages/Reservations/Map/etc).
///
/// Do not use this for drill-down navigation (e.g. list -> detail screen)
/// where the user should be able to return to the previous screen with back.
/// Use Navigator.push directly for that instead.
void navigateToPage(BuildContext context, Widget page) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => page),
  );
}

/// Lets code that has no `BuildContext` reach the navigator — specifically
/// [ApiClient], which has to send the user to the login screen the moment the
/// API answers `401`.
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

void resetTo(BuildContext context, Widget page) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (context) => page),
    (route) => false,
  );
}

void resetToLogin() {
  final navigator = appNavigatorKey.currentState;
  if (navigator == null) return;

  navigator.pushAndRemoveUntil(
    MaterialPageRoute(builder: (context) => const LoginPage()),
    (route) => false,
  );
}

bool _redirectingToLogin = false;

/// Drops the whole stack and shows the login screen.
///
/// Called from the API client after an expired or rejected token, so the user
/// is not left tapping around screens whose every request now fails. Several
/// requests can come back `401` at once — the guard keeps that from pushing
/// the login screen more than once.
void redirectToLogin() {
  if (_redirectingToLogin) return;
  if (appNavigatorKey.currentState == null) return;

  _redirectingToLogin = true;
  resetToLogin();
  WidgetsBinding.instance.addPostFrameCallback(
    (_) => _redirectingToLogin = false,
  );
}
