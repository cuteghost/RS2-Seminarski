import 'package:ebooking/config/app_theme.dart';
import 'package:ebooking/screens/customer_screens/discover_screen.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

class ReservationConfirmationPage extends StatelessWidget {
  final String accommodationName;

  const ReservationConfirmationPage({super.key, required this.accommodationName});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
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
              child: Icon(PhosphorIcons.check(), size: 36, color: AppColors.accent),
            ),
            const SizedBox(height: 28),
            Text(
              'You\u2019re all booked',
              style: textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Your stay at $accommodationName is confirmed and paid.',
              style: textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (context) => const DiscoverPropertiesPage()));
                },
                child: const Text('Back to explore'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
