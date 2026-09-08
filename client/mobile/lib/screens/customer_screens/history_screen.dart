import 'package:ebooking/config/app_theme.dart';
import 'package:ebooking/models/reservation_model.dart';
import 'package:ebooking/providers/reservation_provider.dart';
import 'package:ebooking/services/api_client.dart';
import 'package:ebooking/config/app_constants.dart';
import 'package:ebooking/providers/auth_provider.dart';
import 'package:ebooking/widgets/custom_bottom_navigation_bar.dart';
import 'package:ebooking/widgets/custom_partner_bottom_navigation_bar.dart';
import 'package:ebooking/widgets/remote_image.dart';
import 'package:flutter/material.dart';
import 'package:ebooking/screens/customer_screens/checkout_screen.dart';
import 'package:ebooking/screens/customer_screens/feedback_screen.dart';
import 'package:ebooking/screens/customer_screens/review_screen.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

bool startsAfterToday(DateTime startDate) {
  final now = DateTime.now().toUtc();
  return DateTime.utc(
    startDate.year,
    startDate.month,
    startDate.day,
  ).isAfter(DateTime.utc(now.year, now.month, now.day));
}

Color statusColor(ReservationStatus status) {
  switch (status) {
    case ReservationStatus.confirmed:
      return AppColors.success;
    case ReservationStatus.pending:
      return AppColors.accentText;
    case ReservationStatus.rejected:
      return AppColors.error;
    case ReservationStatus.cancelled:
    case ReservationStatus.completed:
    case ReservationStatus.unknown:
      return AppColors.textTertiary;
  }
}

class ReservationHistoryPage extends StatefulWidget {
  const ReservationHistoryPage({super.key});

  @override
  State<ReservationHistoryPage> createState() => _ReservationHistoryPageState();
}

class _ReservationHistoryPageState extends State<ReservationHistoryPage> {
  late Future<List<ReservationGET>> _trips;

  @override
  void initState() {
    super.initState();
    _trips = _load();
  }

  Future<List<ReservationGET>> _load() => Provider.of<ReservationProvider>(
    context,
    listen: false,
  ).fetchMyReservations();

  void _reload() => setState(() => _trips = _load());

  Future<void> _cancel(ReservationGET reservation) async {
    final reason = await _confirmCancellation(reservation);
    if (reason == null || !mounted) return;

    try {
      await Provider.of<ReservationProvider>(
        context,
        listen: false,
      ).cancelReservation(
        reservation.id,
        reason: reason.isEmpty ? null : reason,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('The stay was cancelled.')));
      _reload();
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  Future<void> _pay(ReservationGET reservation) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutScreen.forExistingBooking(
          reservationId: reservation.id,
          accommodationName: reservation.accommodation?.name ?? 'your stay',
        ),
      ),
    );
    if (!mounted) return;
    _reload();
  }

  Future<String?> _confirmCancellation(ReservationGET reservation) async {
    final controller = TextEditingController();
    final textTheme = Theme.of(context).textTheme;

    try {
      return await showDialog<String>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Cancel this stay?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cancelling ${reservation.accommodation?.name ?? 'this stay'} '
                'cannot be undone. The dates are released and the booking '
                'stays cancelled.',
                style: textTheme.bodySmall,
              ),
              const SizedBox(height: 14),
              TextField(
                controller: controller,
                maxLength: 500,
                decoration: const InputDecoration(
                  labelText: 'Reason (optional)',
                  helperText: 'The host is told why.',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Keep it'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(controller.text.trim()),
              child: const Text('Cancel stay'),
            ),
          ],
        ),
      );
    } finally {
      controller.dispose();
    }
  }

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
                future: _trips,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          '${snapshot.error}',
                          style: textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  final reservations = snapshot.data ?? [];
                  final now = DateTime.now();

                  bool isUpcoming(ReservationGET r) =>
                      r.isActive && r.endDate.isAfter(now);
                  bool isClosed(ReservationGET r) =>
                      r.status == ReservationStatus.cancelled ||
                      r.status == ReservationStatus.rejected;

                  final upcoming = reservations.where(isUpcoming).toList()
                    ..sort((a, b) => a.startDate.compareTo(b.startDate));
                  final past =
                      reservations
                          .where((r) => !isUpcoming(r) && !isClosed(r))
                          .toList()
                        ..sort((a, b) => b.startDate.compareTo(a.startDate));
                  final closed = reservations.where(isClosed).toList()
                    ..sort((a, b) => b.startDate.compareTo(a.startDate));
                  final needsReview =
                      reservations
                          .where(
                            (r) =>
                                r.status == ReservationStatus.completed &&
                                !r.isRated,
                          )
                          .toList()
                        ..sort((a, b) => b.startDate.compareTo(a.startDate));

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
                          _TripCard(
                            reservation: r,
                            onCancel: () => _cancel(r),
                            onPay: r.isPaid ? null : () => _pay(r),
                          ),
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
                          _TripCard(
                            reservation: r,
                            muted: true,
                            // The review lives on the accommodation, so it is
                            // offered exactly where the reservation says one
                            // was left -- and nowhere a second one could be
                            // started.
                            onViewReview:
                                r.status == ReservationStatus.completed &&
                                    r.isRated
                                ? () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ReviewScreen(
                                        accommodationId: r.accommodationId,
                                        accommodationName:
                                            r.accommodation?.name ?? '',
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(height: 14),
                        ],
                      ],
                      if (closed.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          'CANCELLED & DECLINED',
                          style: textTheme.labelSmall,
                        ),
                        const SizedBox(height: 10),
                        for (final r in closed) ...[
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
      bottomNavigationBar:
          Provider.of<AuthProvider>(context, listen: false).role ==
              Roles.partner
          ? const CustomPartnerBottomNavigationBar(currentIndex: 1)
          : const CustomBottomNavigationBar(currentIndex: 1),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;

  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(AppColors.radiusSm),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10.5, color: color, letterSpacing: 0.4),
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  final ReservationGET reservation;
  final bool muted;
  final Future<void> Function()? onCancel;
  final Future<void> Function()? onPay;
  final VoidCallback? onViewReview;

  const _TripCard({
    required this.reservation,
    this.muted = false,
    this.onCancel,
    this.onPay,
    this.onViewReview,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final accommodation = reservation.accommodation;
    final dateRange =
        '${DateFormat('d MMM').format(reservation.startDate)} – ${DateFormat('d MMM').format(reservation.endDate)}';
    final nights = reservation.endDate.difference(reservation.startDate).inDays;
    final daysUntil = reservation.startDate.difference(DateTime.now()).inDays;
    final canCancel = startsAfterToday(reservation.startDate);
    final reason = reservation.statusReason;

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
              child: RemoteImage(
                path: reservation.thumbnailUrl,
                width: 76,
                height: 76,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _Chip(
                          label: reservation.status.label.toUpperCase(),
                          color: statusColor(reservation.status),
                        ),
                        if (!muted && reservation.isActive && daysUntil >= 0)
                          _Chip(
                            label: daysUntil == 0
                                ? 'TODAY'
                                : 'IN $daysUntil DAYS',
                            color: AppColors.accentText,
                          ),
                      ],
                    ),
                  ),
                  Text(accommodation?.name ?? '', style: textTheme.titleMedium),
                  Text(
                    '$dateRange · $nights nights · ${reservation.numberOfGuests} guests',
                    style: textTheme.bodySmall,
                  ),
                  if (accommodation != null)
                    Text(
                      accommodation.location.address,
                      style: textTheme.bodySmall,
                    ),
                  if (reason != null && reason.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Reason: $reason',
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                  if (onCancel != null ||
                      onPay != null ||
                      onViewReview != null) ...[
                    const SizedBox(height: 9),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        if (onViewReview != null)
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 7,
                              ),
                            ),
                            onPressed: onViewReview,
                            child: const Text('Your review'),
                          ),
                        if (onPay != null)
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 7,
                              ),
                            ),
                            onPressed: onPay,
                            child: const Text('Pay'),
                          ),
                        if (onCancel != null)
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 7,
                              ),
                            ),
                            onPressed: canCancel ? onCancel : null,
                            child: const Text('Cancel'),
                          ),
                      ],
                    ),
                    if (onCancel != null && !canCancel)
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          'Your stay has already started, so only an administrator can cancel it now.',
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ),
                  ],
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
            child: RemoteImage(
              path: reservation.thumbnailUrl,
              width: 52,
              height: 52,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reservation.accommodation?.name ?? '',
                  style: textTheme.titleMedium,
                ),
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
                    accommodationID: reservation.accommodationId,
                  ),
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
