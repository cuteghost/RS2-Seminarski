import 'package:ebooking/config/app_theme.dart';
import 'package:ebooking/providers/message_provider.dart';
import 'package:ebooking/providers/auth_provider.dart';
import 'package:ebooking/screens/customer_screens/history_screen.dart';
import 'package:ebooking/screens/customer_screens/discover_screen.dart';
import 'package:ebooking/screens/messenger_screen.dart';
import 'package:flutter/material.dart';
import 'package:ebooking/utils/navigation_utils.dart';
import 'package:ebooking/screens/customer_screens/profile_screen.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:provider/provider.dart';

/// The customer bottom tab bar -- Explore / Trips / Inbox / Profile.
///
/// [currentIndex] tells the bar which destination is "active" so it can
/// highlight it (design system requires a real selected state -- the old bar
/// never showed which of its five destinations you were on). Map and
/// Suggestions moved out of the primary nav (redesign scope note: "not
/// covered here") -- reach them from the Explore screen's search bar
/// (map) and the "Suggested for you" section (suggestions) instead, so
/// neither becomes unreachable.
class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavigationBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<AuthProvider>(context, listen: false).userId;

    return Consumer<MessageProvider>(
      builder: (context, messageProvider, child) {
        int unread = 0;
        for (var c in messageProvider.chats) {
          for (var m in c.messages) {
            if (m.isRead == false && m.sender != userId) {
              unread++;
            }
          }
        }

        return NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (index) {
            if (index == currentIndex) return;
            switch (index) {
              case 0:
                navigateToPage(context, const DiscoverPropertiesPage());
                break;
              case 1:
                navigateToPage(context, const ReservationHistoryPage());
                break;
              case 2:
                navigateToPage(context, const ContactListScreen());
                break;
              case 3:
                navigateToPage(context, const ProfilePage());
                break;
            }
          },
          destinations: [
            NavigationDestination(
              icon: Icon(PhosphorIcons.compass()),
              selectedIcon: Icon(
                PhosphorIcons.compass(PhosphorIconsStyle.fill),
                color: AppColors.accent,
              ),
              label: 'Explore',
            ),
            NavigationDestination(
              icon: Icon(PhosphorIcons.suitcaseSimple()),
              selectedIcon: Icon(
                PhosphorIcons.suitcaseSimple(PhosphorIconsStyle.fill),
                color: AppColors.accent,
              ),
              label: 'Trips',
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
