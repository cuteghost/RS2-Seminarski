import 'package:ebooking/config/app_theme.dart';
import 'package:ebooking/models/reservation_model.dart';
import 'package:ebooking/providers/reservation_provider.dart';
import 'package:ebooking/widgets/custom_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:ebooking/screens/customer_screens/feedback_screen.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ReservationHistoryPage extends StatelessWidget {
  const ReservationHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Text('Trips', style: textTheme.headlineMedium),
            ),
            Expanded(
              child: FutureBuilder<List<ReservationGET>>(
                future: Provider.of<ReservationProvider>(context, listen: false)
                    .fetchMyReservations(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}',
                          style: textTheme.bodySmall),
                    );
                  }

                  final reservations = snapshot.data ?? [];
                  final now = DateTime.now();
                  final upcoming = reservations
                      .where((r) => r.endDate.isAfter(now))
                      .toList()
                    ..sort((a, b) => a.startDate.compareTo(b.startDate));
                  final past = reservations
                      .where((r) => r.endDate.isBefore(now))
                      .toList()
                    ..sort((a, b) => b.startDate.compareTo(a.startDate));
                  final needsReview =
                      past.where((r) => !r.isRated).toList();

                  if (reservations.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          'No trips yet. Once you book a stay, it shows up here.',
                          style: textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                    children: [
                      if (upcoming.isNotEmpty) ...[
                        Text('UPCOMING', style: textTheme.labelSmall),
                        const SizedBox(height: 10),
                        for (final r in upcoming) ...[
                          _TripCard(reservation: r),
                          const SizedBox(height: 14),
                        ],
                      ],
                      if (needsReview.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text('NEEDS YOUR REVIEW', style: textTheme.labelSmall),
                        const SizedBox(height: 10),
                        for (final r in needsReview) ...[
                          _ReviewPromptCard(reservation: r),
                          const SizedBox(height: 12),
                        ],
                      ],
                      if (past.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text('PAST', style: textTheme.labelSmall),
                        const SizedBox(height: 10),
                        for (final r in past) ...[
                          _TripCard(reservation: r, muted: true),
                          const SizedBox(height: 14),
                        ],
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 1),
    );
  }
}

class _TripCard extends StatelessWidget {
  final ReservationGET reservation;
  final bool muted;

  const _TripCard({required this.reservation, this.muted = false});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final accommodation = reservation.accommodation;
    final dateRange =
        '${DateFormat('d MMM').format(reservation.startDate)} – ${DateFormat('d MMM').format(reservation.endDate)}';
    final nights = reservation.endDate.difference(reservation.startDate).inDays;
    final daysUntil = reservation.startDate.difference(DateTime.now()).inDays;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppColors.radiusMd),
      ),
      child: Padding(
        padding: const EdgeInsets.all(13),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.file(
                reservation.thumbnail,
                width: 76,
                height: 76,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!muted && daysUntil >= 0)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.accent),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          daysUntil == 0 ? 'TODAY' : 'IN $daysUntil DAYS',
                          style: const TextStyle(
                              fontSize: 10.5,
                              color: AppColors.accentText,
                              letterSpacing: 0.4),
                        ),
                      ),
                    ),
                  Text(accommodation?.name ?? '', style: textTheme.titleMedium),
                  Text('$dateRange · $nights nights · ${reservation.numberOfGuests} guests',
                      style: textTheme.bodySmall),
                  if (accommodation != null)
                    Text(accommodation.location.address, style: textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewPromptCard extends StatelessWidget {
  final ReservationGET reservation;

  const _ReviewPromptCard({required this.reservation});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppColors.radiusMd),
      ),
      padding: const EdgeInsets.all(13),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.file(
              reservation.thumbnail,
              width: 52,
              height: 52,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(reservation.accommodation?.name ?? '',
                    style: textTheme.titleMedium),
                Text(
                  'Stayed ${DateFormat('d MMM').format(reservation.startDate)} – ${DateFormat('d MMM').format(reservation.endDate)}',
                  style: textTheme.bodySmall,
                ),
              ],
            ),
          ),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FeedbackPage(
                      accommodationID: reservation.accommodationId),
                ),
              );
            },
            child: const Text('Rate'),
          ),
        ],
      ),
    );
  }
}
