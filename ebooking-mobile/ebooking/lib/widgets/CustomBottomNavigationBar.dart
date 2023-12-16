// bottom_navigation_bar.dart

import 'package:flutter/material.dart';
import 'package:ebooking/utils/navigation_utils.dart';
import 'package:ebooking/maps.dart';
import 'package:ebooking/profile_page.dart';
import 'package:ebooking/suggestions_page.dart';

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
