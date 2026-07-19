import 'package:ebooking/config/app_theme.dart';
import 'package:ebooking/models/reservation_model.dart';
import 'package:ebooking/providers/message_provider.dart';
import 'package:ebooking/providers/reservation_provider.dart';
import 'package:ebooking/screens/customer_screens/history_screen.dart'
    show statusColor;
import 'package:ebooking/screens/messenger_screen.dart';
import 'package:ebooking/services/api_client.dart';
import 'package:ebooking/widgets/custom_partner_bottom_navigation_bar.dart';
import 'package:ebooking/widgets/remote_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:provider/provider.dart';

bool stayHasEnded(ReservationGET reservation) {
  final now = DateTime.now().toUtc();
  final end = reservation.endDate.toUtc();
  return !DateTime.utc(
    end.year,
    end.month,
    end.day,
  ).isAfter(DateTime.utc(now.year, now.month, now.day));
}

class PartnerBookingsScreen extends StatefulWidget {
  const PartnerBookingsScreen({super.key});

  @override
  State<PartnerBookingsScreen> createState() => _PartnerBookingsScreenState();
}

class _PartnerBookingsScreenState extends State<PartnerBookingsScreen> {
  late Future<List<ReservationGET>> _bookings;
  String? _busyId;

  @override
  void initState() {
    super.initState();
    _bookings = _load();
  }

  Future<List<ReservationGET>> _load() => Provider.of<ReservationProvider>(
    context,
    listen: false,
  ).fetchPartnerReservations();

  void _reload() => setState(() => _bookings = _load());

  Future<void> _apply(
    ReservationGET reservation,
    Future<void> Function() action,
    String success,
  ) async {
    setState(() => _busyId = reservation.id);
    try {
      await action();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(success)));
      setState(() => _busyId = null);
      _reload();
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _busyId = null);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  Future<void> _accept(ReservationGET reservation) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Accept this booking?'),
        content: Text(
          'The dates are held for the guest and you can no longer decline '
          '${reservation.accommodation?.name ?? 'this stay'}.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Not yet'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Accept'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final provider = Provider.of<ReservationProvider>(context, listen: false);
    await _apply(
      reservation,
      () => provider.confirmReservation(reservation.id),
      'The booking is confirmed.',
    );
  }

  Future<void> _decline(ReservationGET reservation) async {
    final reason = await _askDeclineReason(reservation);
    if (reason == null || !mounted) return;

    final provider = Provider.of<ReservationProvider>(context, listen: false);
    await _apply(
      reservation,
      () => provider.rejectReservation(reservation.id, reason: reason),
      'The booking was declined and the guest was told why.',
    );
  }

  Future<String?> _askDeclineReason(ReservationGET reservation) {
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => _DeclineReasonDialog(
        stayName: reservation.accommodation?.name ?? 'this stay',
      ),
    );
  }

  Future<void> _complete(ReservationGET reservation) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Close this stay?'),
        content: Text(
          'The stay is marked as completed and the guest can review it. '
          'This cannot be undone.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Not yet'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Mark completed'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final provider = Provider.of<ReservationProvider>(context, listen: false);
    await _apply(
      reservation,
      () => provider.completeReservation(reservation.id),
      'The stay is closed.',
    );
  }

  (String?, String?) _chatFor(MessageProvider messages, ReservationGuest? guest) {
    if (guest == null) {
      return (null, 'This booking does not say who made it.');
    }
    if (messages.connectionError != null) {
      return (null, messages.connectionError);
    }

    final matches = messages.chats
        .where((chat) => chat.user2 == guest.displayName)
        .toList();
    if (matches.length == 1) return (matches.first.id, null);
    if (matches.length > 1) {
      return (
        null,
        'More than one conversation is open under this name, so the app '
            'cannot tell which one belongs to this guest.',
      );
    }
    return (
      null,
      'The conversation with this guest has not loaded yet. It is opened '
          'together with the booking, so it appears once the inbox is read.',
    );
  }

  Future<void> _openChat(String chatId, String contactName) async {
    final provider = Provider.of<MessageProvider>(context, listen: false);
    await provider.readMessages(chatId);
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            MessengerScreen(contactName: contactName, chatId: chatId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final messages = Provider.of<MessageProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<List<ReservationGET>>(
          future: _bookings,
          builder: (context, snapshot) {
            final bookings = snapshot.data ?? const <ReservationGET>[];
            final requests = bookings
                .where((r) => r.status == ReservationStatus.pending)
                .toList()
              ..sort((a, b) => a.startDate.compareTo(b.startDate));
            final staying =
                bookings
                    .where(
                      (r) =>
                          r.status == ReservationStatus.confirmed &&
                          !stayHasEnded(r),
                    )
                    .toList()
                  ..sort((a, b) => a.startDate.compareTo(b.startDate));
            final toClose =
                bookings
                    .where(
                      (r) =>
                          r.status == ReservationStatus.confirmed &&
                          stayHasEnded(r),
                    )
                    .toList()
                  ..sort((a, b) => a.endDate.compareTo(b.endDate));
            final past = bookings
                .where((r) => r.status == ReservationStatus.completed)
                .toList()
              ..sort((a, b) => b.startDate.compareTo(a.startDate));
            final closed =
                bookings
                    .where(
                      (r) =>
                          r.status == ReservationStatus.cancelled ||
                          r.status == ReservationStatus.rejected,
                    )
                    .toList()
                  ..sort((a, b) => b.startDate.compareTo(a.startDate));

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Bookings', style: textTheme.headlineMedium),
                      const SizedBox(height: 3),
                      Text(
                        requests.isEmpty
                            ? 'Requests for your properties show up here.'
                            : '${requests.length} waiting for your answer',
                        style: textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _body(
                    snapshot,
                    textTheme,
                    messages,
                    requests: requests,
                    staying: staying,
                    toClose: toClose,
                    past: past,
                    closed: closed,
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: const CustomPartnerBottomNavigationBar(
        currentIndex: 1,
      ),
    );
  }

  Widget _body(
    AsyncSnapshot<List<ReservationGET>> snapshot,
    TextTheme textTheme,
    MessageProvider messages, {
    required List<ReservationGET> requests,
    required List<ReservationGET> staying,
    required List<ReservationGET> toClose,
    required List<ReservationGET> past,
    required List<ReservationGET> closed,
  }) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    if (snapshot.hasError) {
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
    if (requests.isEmpty &&
        staying.isEmpty &&
        toClose.isEmpty &&
        past.isEmpty &&
        closed.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'No bookings yet. Once a guest books one of your properties, the '
            'request shows up here.',
            style: textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      children: [
        ..._section('NEEDS YOUR ANSWER', requests, textTheme, messages),
        ..._section('STAYING', staying, textTheme, messages),
        ..._section('READY TO CLOSE', toClose, textTheme, messages),
        ..._section('COMPLETED', past, textTheme, messages),
        ..._section('CANCELLED & DECLINED', closed, textTheme, messages),
      ],
    );
  }

  List<Widget> _section(
    String title,
    List<ReservationGET> reservations,
    TextTheme textTheme,
    MessageProvider messages,
  ) {
    if (reservations.isEmpty) return const <Widget>[];

    return [
      Text(title, style: textTheme.labelSmall),
      const SizedBox(height: 10),
      for (final reservation in reservations) ...[
        Builder(
          builder: (context) {
            final (chatId, chatUnavailable) = _chatFor(
              messages,
              reservation.guest,
            );
            return _BookingCard(
              reservation: reservation,
              busy: _busyId == reservation.id,
              chatUnavailable: chatUnavailable,
              onMessage: chatId == null
                  ? null
                  : () => _openChat(
                      chatId,
                      reservation.guest?.displayName ?? '',
                    ),
              onAccept: reservation.status == ReservationStatus.pending
                  ? () => _accept(reservation)
                  : null,
              onDecline: reservation.status == ReservationStatus.pending
                  ? () => _decline(reservation)
                  : null,
              onComplete: reservation.status == ReservationStatus.confirmed
                  ? () => _complete(reservation)
                  : null,
            );
          },
        ),
        const SizedBox(height: 14),
      ],
      const SizedBox(height: 6),
    ];
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

class _GuestRow extends StatelessWidget {
  final ReservationGuest guest;

  const _GuestRow({required this.guest});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          ClipOval(
            child: SizedBox(
              width: 24,
              height: 24,
              child: guest.imageUrl == null
                  ? Container(
                      color: AppColors.accentTint,
                      child: Icon(
                        PhosphorIcons.user(),
                        size: 13,
                        color: AppColors.accentLink,
                      ),
                    )
                  : RemoteImage(path: guest.imageUrl, width: 24, height: 24),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              guest.name,
              style: textTheme.bodyMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final ReservationGET reservation;
  final bool busy;
  final String? chatUnavailable;
  final Future<void> Function()? onMessage;
  final Future<void> Function()? onAccept;
  final Future<void> Function()? onDecline;
  final Future<void> Function()? onComplete;

  const _BookingCard({
    required this.reservation,
    required this.busy,
    this.chatUnavailable,
    this.onMessage,
    this.onAccept,
    this.onDecline,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final accommodation = reservation.accommodation;
    final guest = reservation.guest;
    final dateRange =
        '${DateFormat('d MMM').format(reservation.startDate)} – ${DateFormat('d MMM').format(reservation.endDate)}';
    final nights = reservation.endDate.difference(reservation.startDate).inDays;
    final canClose = stayHasEnded(reservation);
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
                        _Chip(
                          label: reservation.isPaid ? 'PAID' : 'NOT PAID',
                          color: reservation.isPaid
                              ? AppColors.success
                              : AppColors.textTertiary,
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
                  if (guest != null) _GuestRow(guest: guest),
                  if (onAccept != null ||
                      onDecline != null ||
                      onComplete != null ||
                      guest != null) ...[
                    const SizedBox(height: 9),
                    if (busy)
                      const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          if (guest != null)
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 7,
                                ),
                              ),
                              onPressed: onMessage,
                              child: const Text('Message'),
                            ),
                          if (onAccept != null)
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 7,
                                ),
                              ),
                              onPressed: onAccept,
                              child: const Text('Accept'),
                            ),
                          if (onDecline != null)
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 7,
                                ),
                              ),
                              onPressed: onDecline,
                              child: const Text('Decline'),
                            ),
                          if (onComplete != null)
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 7,
                                ),
                              ),
                              onPressed: canClose ? onComplete : null,
                              child: const Text('Mark completed'),
                            ),
                        ],
                      ),
                    if (onComplete != null && !canClose && !busy)
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          'The stay can be closed once the guest has checked '
                          'out on ${DateFormat('d MMM').format(reservation.endDate)}.',
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ),
                    if (guest != null &&
                        onMessage == null &&
                        chatUnavailable != null &&
                        !busy)
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          chatUnavailable!,
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

class _DeclineReasonDialog extends StatefulWidget {
  const _DeclineReasonDialog({required this.stayName});

  final String stayName;

  @override
  State<_DeclineReasonDialog> createState() => _DeclineReasonDialogState();
}

class _DeclineReasonDialogState extends State<_DeclineReasonDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final reason = _controller.text.trim();

    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: const Text('Decline this booking?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Declining ${widget.stayName} cannot be undone. The dates are '
            'released.',
            style: textTheme.bodySmall,
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _controller,
            maxLength: 500,
            autofocus: true,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'Reason',
              helperText: 'The guest is told why, so this is required.',
            ),
          ),
          if (reason.isEmpty)
            Text(
              'Write a reason to be able to decline.',
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Keep it'),
        ),
        TextButton(
          onPressed: reason.isEmpty
              ? null
              : () => Navigator.of(context).pop(reason),
          child: const Text('Decline'),
        ),
      ],
    );
  }
}
