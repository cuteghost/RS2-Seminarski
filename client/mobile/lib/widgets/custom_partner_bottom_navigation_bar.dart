// bottom_navigation_bar.dart

import 'package:ebooking/providers/message_provider.dart';
import 'package:ebooking/providers/profile_provider.dart';
import 'package:ebooking/screens/customer_screens/history_screen.dart';
import 'package:ebooking/screens/customer_screens/maps_screen.dart';
import 'package:ebooking/screens/messenger_screen.dart';
import 'package:ebooking/screens/partner_screens/my_accommodations_screens.dart';
import 'package:ebooking/screens/partner_screens/partner_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:ebooking/utils/navigation_utils.dart';
import 'package:ebooking/screens/partner_screens/add_accommodation_screen.dart';
import 'package:ebooking/widgets/custom_icon_button.dart';
import 'package:icon_badge/icon_badge.dart';
import 'package:provider/provider.dart';

class CustomPartnerBottomNavigationBar extends StatefulWidget {
  const CustomPartnerBottomNavigationBar({super.key});

  @override
  CustomPartnerBottomNavigationBarState createState() =>
      CustomPartnerBottomNavigationBarState();
}

class CustomPartnerBottomNavigationBarState
    extends State<CustomPartnerBottomNavigationBar> {
  @override
  Widget build(BuildContext context) {
    var profile = Provider.of<ProfileProvider>(context, listen: false).profile;
    return Consumer<MessageProvider>(
        builder: (context, messageProvider, child) {
      int counter = 0;
      for (var c in messageProvider.chats) {
        for (var m in c.messages) {
          if (m.isRead == false && m.sender != profile.id) {
            counter++;
          }
        }
      }
      return BottomAppBar(
          color: Colors.blue,
          padding: EdgeInsets.zero,
          notchMargin: 0.0,
          height: 48,
          child: SizedBox(
              height: 20,
              child: IconTheme(
                data: IconThemeData(
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 25,
                  opticalSize: 20,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const SizedBox(width: 20),
                    CustomIconButton(
                        icon: counter != 0
                            ? IconBadge(
                                icon: const Icon(Icons.message),
                                itemCount: counter,
                                badgeColor: Colors.red,
                                itemColor: Colors.white,
                                maxCount: 99,
                                hideZero: true)
                            : const Icon(Icons.message),
                        label: 'Messages',
                        onPressed: () {
                          navigateToPage(context, const ContactListScreen());
                        }),
                    CustomIconButton(
                        icon: const Icon(Icons.home),
                        label: 'Properties',
                        onPressed: () {
                          navigateToPage(
                              context, const MyAccommodationsScreen());
                        }),
                    CustomIconButton(
                        icon: const Icon(Icons.add),
                        label: 'Add Property',
                        onPressed: () {
                          navigateToPage(
                              context, const AddAccommodationScreen());
                        }),
                    CustomIconButton(
                        icon: const Icon(Icons.person),
                        label: 'Profile',
                        onPressed: () {
                          navigateToPage(context, const PartnerProfilePage());
                        }),
                    CustomIconButton(
                        icon: const Icon(Icons.work_history),
                        label: 'Reservations',
                        onPressed: () {
                          navigateToPage(
                              context, const ReservationHistoryPage());
                        }),
                    CustomIconButton(
                        icon: const Icon(Icons.map),
                        label: 'Map',
                        onPressed: () {
                          navigateToPage(context, const MapPage());
                        }),
                    const SizedBox(width: 20),
                  ],
                ),
              )));
    });
  }
}
