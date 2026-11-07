import 'package:ebooking/config/app_theme.dart';
import 'package:ebooking/screens/customer_screens/discover_screen.dart';
import 'package:ebooking/screens/customer_screens/history_screen.dart';
import 'package:ebooking/utils/navigation_utils.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

class ReservationConfirmationPage extends StatelessWidget {
  final String accommodationName;
  final bool paid;

  const ReservationConfirmationPage({
    super.key,
    required this.accommodationName,
  }) : paid = true;

  const ReservationConfirmationPage.unpaid({
    super.key,
    required this.accommodationName,
  }) : paid = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // The booking is done, so neither way back may lead into the flow that
    // made it: the screen behind this one is the calendar or the payment step
    // of a reservation that already exists. The system back button is given
    // the same destination as the screen's own last action.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        resetTo(context, const DiscoverPropertiesPage());
      },
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.accent, width: 1.5),
                ),
                child: Icon(
                  paid ? PhosphorIcons.check() : PhosphorIcons.clock(),
                  size: 36,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                paid ? 'You’re all booked' : 'Booking request sent',
                style: textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                paid
                    ? 'Your payment for $accommodationName went through. Your stay is confirmed and paid, and you can find it under Trips.'
                    : 'Your request for $accommodationName was sent to the host. Once the host confirms it, you can pay from Trips.',
                style: textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              if (!paid) ...[
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () =>
                        resetTo(context, const ReservationHistoryPage()),
                    child: const Text('Go to Trips'),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () =>
                      resetTo(context, const DiscoverPropertiesPage()),
                  child: const Text('Back to explore'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
