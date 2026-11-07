import 'package:ebooking/config/app_theme.dart';
import 'package:ebooking/providers/message_provider.dart';
import 'package:ebooking/providers/notification_provider.dart';
import 'package:ebooking/screens/notifications_screen.dart';
import 'package:ebooking/screens/messenger_screen.dart';
import 'package:ebooking/screens/partner_screens/my_accommodations_screen.dart';
import 'package:ebooking/screens/partner_screens/partner_bookings_screen.dart';
import 'package:ebooking/screens/partner_screens/partner_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:ebooking/utils/navigation_utils.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:provider/provider.dart';

/// The partner bottom tab bar -- Listings / Bookings / Inbox / Profile.
///
/// "Add property" and "Map" moved out of the bar (redesign scope note under
/// Partner Properties: "Add belongs on the screen it creates from, not in
/// navigation"). Add lives as a button on [MyAccommodationsScreen]; Map is
/// still reachable from there too, same as the customer Explore screen.
class CustomPartnerBottomNavigationBar extends StatelessWidget {
  final int currentIndex;

  const CustomPartnerBottomNavigationBar({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<MessageProvider, NotificationProvider>(
      builder: (context, messageProvider, notificationProvider, child) {
        final unread = messageProvider.unreadCount;
        final alerts = notificationProvider.unreadCount;

        return NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (index) {
            if (index == currentIndex) return;
            switch (index) {
              case 0:
                navigateToPage(context, const MyAccommodationsScreen());
                break;
              case 1:
                navigateToPage(context, const PartnerBookingsScreen());
                break;
              case 2:
                navigateToPage(context, const ContactListScreen());
                break;
              case 3:
                navigateToPage(context, const NotificationsScreen());
                break;
              case 4:
                navigateToPage(context, const PartnerProfilePage());
                break;
            }
          },
          destinations: [
            NavigationDestination(
              icon: Icon(PhosphorIcons.houseLine()),
              selectedIcon: Icon(
                PhosphorIcons.houseLine(PhosphorIconsStyle.fill),
                color: AppColors.accent,
              ),
              label: 'Listings',
            ),
            NavigationDestination(
              icon: Icon(PhosphorIcons.calendarCheck()),
              selectedIcon: Icon(
                PhosphorIcons.calendarCheck(PhosphorIconsStyle.fill),
                color: AppColors.accent,
              ),
              label: 'Bookings',
            ),
            NavigationDestination(
              icon: unread > 0
                  ? Badge(
                      label: Text('$unread'),
                      backgroundColor: AppColors.accent,
                      textColor: AppColors.bg,
                      child: Icon(PhosphorIcons.chatCircle()),
                    )
                  : Icon(PhosphorIcons.chatCircle()),
              selectedIcon: Icon(
                PhosphorIcons.chatCircle(PhosphorIconsStyle.fill),
                color: AppColors.accent,
              ),
              label: 'Inbox',
            ),
            NavigationDestination(
              icon: alerts > 0
                  ? Badge(
                      label: Text('$alerts'),
                      backgroundColor: AppColors.accent,
                      textColor: AppColors.bg,
                      child: Icon(PhosphorIcons.bell()),
                    )
                  : Icon(PhosphorIcons.bell()),
              selectedIcon: Icon(
                PhosphorIcons.bell(PhosphorIconsStyle.fill),
                color: AppColors.accent,
              ),
              label: 'Alerts',
            ),
            NavigationDestination(
              icon: Icon(PhosphorIcons.user()),
              selectedIcon: Icon(
                PhosphorIcons.user(PhosphorIconsStyle.fill),
                color: AppColors.accent,
              ),
              label: 'Profile',
            ),
          ],
        );
      },
    );
  }
}
