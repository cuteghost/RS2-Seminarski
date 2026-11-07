import 'package:ebooking/config/app_constants.dart';
import 'package:ebooking/config/app_theme.dart';
import 'package:ebooking/models/notification_model.dart';
import 'package:ebooking/providers/auth_provider.dart';
import 'package:ebooking/providers/notification_provider.dart';
import 'package:ebooking/services/api_client.dart';
import 'package:ebooking/widgets/custom_bottom_navigation_bar.dart';
import 'package:ebooking/widgets/custom_partner_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:provider/provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  static const int navigationIndex = 3;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationProvider>(context, listen: false).load();
    });
  }

  IconData _iconFor(NotificationType type) {
    switch (type) {
      case NotificationType.paymentCompleted:
        return PhosphorIcons.creditCard();
      case NotificationType.reservationCancelled:
        return PhosphorIcons.xCircle();
      case NotificationType.reservationCreated:
        return PhosphorIcons.calendarPlus();
      case NotificationType.passwordChanged:
        return PhosphorIcons.lock();
      default:
        return PhosphorIcons.bell();
    }
  }

  Future<void> _markAll(NotificationProvider provider) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await provider.markAllRead();
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _open(NotificationProvider provider, AppNotification item) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await provider.markRead(item);
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isPartner =
        Provider.of<AuthProvider>(context, listen: false).role == Roles.partner;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, provider, _) => TextButton(
              onPressed: provider.unreadCount == 0
                  ? null
                  : () => _markAll(provider),
              child: const Text('Mark all read'),
            ),
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final error = provider.error;
          if (error != null && provider.items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(error, style: textTheme.bodySmall),
                    TextButton(
                      onPressed: provider.load,
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (provider.items.isEmpty) {
            return Center(
              child: Text(
                'No notifications yet.',
                style: textTheme.bodySmall,
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: provider.load,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: provider.items.length + (provider.hasMore ? 1 : 0),
              separatorBuilder: (_, _) =>
                  Divider(color: AppColors.divider, height: 1, indent: 68),
              itemBuilder: (context, index) {
                if (index == provider.items.length) {
                  return Center(
                    child: TextButton(
                      onPressed: provider.isLoading ? null : provider.loadMore,
                      child: const Text('Load older'),
                    ),
                  );
                }

                final item = provider.items[index];
                return ListTile(
                  onTap: () => _open(provider, item),
                  leading: CircleAvatar(
                    backgroundColor: item.isRead
                        ? AppColors.surface
                        : AppColors.accentTint,
                    child: Icon(
                      _iconFor(item.type),
                      size: 18,
                      color: item.isRead
                          ? AppColors.textTertiary
                          : AppColors.accentLink,
                    ),
                  ),
                  title: Text(
                    item.title,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: item.isRead
                          ? FontWeight.normal
                          : FontWeight.w600,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 2),
                      Text(item.body, style: textTheme.bodySmall),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('d MMM y, HH:mm').format(item.createdAt),
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  trailing: item.isRead
                      ? null
                      : Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: isPartner
          ? const CustomPartnerBottomNavigationBar(
              currentIndex: NotificationsScreen.navigationIndex,
            )
          : const CustomBottomNavigationBar(
              currentIndex: NotificationsScreen.navigationIndex,
            ),
    );
  }
}
