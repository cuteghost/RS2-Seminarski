import 'package:ebooking/models/message_model.dart';
import 'package:ebooking/providers/message_provider.dart';
import 'package:ebooking/providers/profile_provider.dart';
import 'package:ebooking/screens/customer_screens/history_screen.dart';
import 'package:ebooking/screens/messenger_screen.dart';
import 'package:flutter/material.dart';
import 'package:ebooking/utils/navigation_utils.dart';
import 'package:ebooking/screens/customer_screens/maps_screen.dart';
import 'package:ebooking/screens/customer_screens/profile_screen.dart';
import 'package:ebooking/screens/customer_screens/suggestions_screen.dart';
import 'package:provider/provider.dart';
import 'package:icon_badge/icon_badge.dart';
import 'package:ebooking/widgets/customIconButton.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  @override
  _CustomBottomNavigationBarState createState() => _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  final List<Widget> _pages = [
    ContactListScreen(),
    ReservationHistoryPage(),
    SuggestionsForYou(),
    ProfilePage(),
    MapPage(),
  ];
  @override
  Widget build(BuildContext context) {
    var profile = Provider.of<ProfileProvider>(context, listen: false).profile;
    return Consumer<MessageProvider>(
      builder: (context,messageProvider, child){
        int counter = 0;
        messageProvider.chats.forEach((c) {
          c.Messages.forEach((m) {
            if (m.IsRead == false && m.Sender != profile.id) {
              counter++;
            }
          });
        });
        return BottomAppBar(
          color: Colors.blue,
          padding: EdgeInsets.zero,
          notchMargin: 0.0,
          height: 48,
          child: SizedBox(
            height: 20,
            child: IconTheme(
              data: IconThemeData(color: Theme.of(context).colorScheme.onPrimary, size: 25, opticalSize: 20, ),
              child: Row(
                
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  SizedBox(width: 20),
                  CustomIconButton(icon: counter!= 0 ? IconBadge(icon: Icon(Icons.message), itemCount: counter, badgeColor: Colors.red, itemColor: Colors.white, maxCount: 99, hideZero: true) : Icon(Icons.message), label: 'Messages', onPressed: () {
                    navigateToPage(context, ContactListScreen());
                  }),
                  CustomIconButton(icon: Icon(Icons.work_history), label: 'Reservations', onPressed: () {
                    navigateToPage(context, ReservationHistoryPage());
                  }),
                  CustomIconButton(icon: Icon(Icons.flag), label: 'Suggestions', onPressed: () {
                    navigateToPage(context, SuggestionsForYou());
                  }),
                  CustomIconButton(icon: Icon(Icons.person), label: 'Profile', onPressed: () {
                    navigateToPage(context, ProfilePage());
                  }),
                  CustomIconButton(icon: Icon(Icons.map), label: 'Map', onPressed: () {
                    navigateToPage(context, MapPage());
                  }),
                  SizedBox(width: 20),
                ],
              ),
            )
          )
        );
      }
    );
  }
}
