// bottom_navigation_bar.dart

import 'package:flutter/material.dart';
import 'package:ebooking/utils/navigation_utils.dart';
import 'package:ebooking/screens/maps_screen.dart';
import 'package:ebooking/screens/profile_screen.dart';
import 'package:ebooking/screens/suggestions_screen.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final List<Widget> _pages = [
    MapPage(),
    SuggestionsForYou(),
    ProfilePage(),
  ];

  CustomBottomNavigationBar();

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.map),
          label: 'Map',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.flag),
          label: 'Suggestions',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
      onTap: (index) {
        navigateToPage(context, _pages[index]);
      },
    );
  }
}
