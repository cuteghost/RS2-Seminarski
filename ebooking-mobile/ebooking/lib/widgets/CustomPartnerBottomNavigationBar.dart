// bottom_navigation_bar.dart

import 'package:ebooking/screens/partner_screens/partner_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:ebooking/utils/navigation_utils.dart';
import 'package:ebooking/screens/customer_screens/maps_screen.dart';
import 'package:ebooking/screens/partner_screens/add_accommodation_screen.dart';

class CustomPartnerBottomNavigationBar extends StatelessWidget {
  final List<Widget> _pages = [
    MapPage(),
    AddAccommodationScreen(),
    PartnerProfilePage(),

  ];

  CustomPartnerBottomNavigationBar();

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Properties',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add),
          label: 'Add Property',
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
