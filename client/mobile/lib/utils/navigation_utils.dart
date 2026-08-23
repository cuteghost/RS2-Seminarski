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
