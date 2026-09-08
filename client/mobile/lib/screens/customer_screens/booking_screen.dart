import 'package:ebooking/config/app_theme.dart';
import 'package:ebooking/models/accommodation_model.dart';
import 'package:ebooking/models/reservation_model.dart';
import 'package:ebooking/providers/reservation_provider.dart';
import 'package:ebooking/services/api_client.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:ebooking/screens/customer_screens/checkout_screen.dart';
import 'package:ebooking/screens/customer_screens/reservation_confirmation_screen.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

enum _PayChoice { now, later }

DateTime dateOnly(DateTime day) => DateTime(day.year, day.month, day.day);

bool isDayTaken(DateTime day, List<DateTimeRange> ranges) {
  final d = dateOnly(day);
  return ranges.any(
    (range) =>
        !d.isBefore(dateOnly(range.start)) && d.isBefore(dateOnly(range.end)),
  );
}

bool rangeOverlaps(DateTime from, DateTime to, List<DateTimeRange> ranges) {
  final f = dateOnly(from);
  final t = dateOnly(to);
  return ranges.any(
    (range) =>
        dateOnly(range.start).isBefore(t) && f.isBefore(dateOnly(range.end)),
  );
}

class BookingScreen extends StatefulWidget {
  final AccommodationGET accommodation;
  final DateTime? checkIn;
  final DateTime? checkOut;

  const BookingScreen({
    super.key,
    required this.accommodation,
    this.checkIn,
    this.checkOut,
  });

  @override
  BookingScreenState createState() => BookingScreenState();
}

class BookingScreenState extends State<BookingScreen> {
  int numberOfGuests = 1;
  DateTime? fromDate;
  DateTime? toDate;
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime firstFreeDay = DateTime.now();
  bool _placing = false;

  @override
  void initState() {
    super.initState();
    _prefillFromSearch();
    _loadReservedDates();
  }

  void _prefillFromSearch() {
    final start = widget.checkIn;
    final end = widget.checkOut;
    if (start == null || end == null) return;

    final from = dateOnly(start);
    final to = dateOnly(end);
    if (!to.isAfter(from) || from.isBefore(dateOnly(DateTime.now()))) return;

    fromDate = from;
    toDate = to;
    firstFreeDay = from;
  }

  Future<void> _loadReservedDates() async {
    try {
      await Provider.of<ReservationProvider>(
        context,
        listen: false,
      ).fetchReservedDates(widget.accommodation.id);
      if (!mounted) return;
      _dropPrefilledRangeIfTaken();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  void _dropPrefilledRangeIfTaken() {
    if (fromDate == null || toDate == null) return;

    final ranges = Provider.of<ReservationProvider>(context, listen: false)
        .reservedDates
        .map((map) => DateTimeRange(start: map['Start']!, end: map['End']!))
        .toList();
    if (!rangeOverlaps(fromDate!, toDate!, ranges)) return;

    setState(() {
      fromDate = null;
      toDate = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'The dates you picked in the search are already booked here. Choose new ones.',
        ),
      ),
    );
  }

  /// A day another booking already holds. Red rather than the greyed-out
  /// strikethrough it used to carry, which read as an ordinary day at a
  /// glance; the line stays so the state is not carried by colour alone.
  Widget _takenDay(DateTime date, {bool outside = false}) {
    final red = outside
        ? AppColors.error.withValues(alpha: 0.55)
        : AppColors.error;
    return Center(
      child: Container(
        height: 36,
        width: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.error.withValues(alpha: outside ? 0.07 : 0.14),
        ),
        child: Center(
          child: Text(
            date.day.toString(),
            style: TextStyle(
              color: red,
              decoration: TextDecoration.lineThrough,
              decorationColor: red,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openCheckout(int nights) async {
    if (_placing) return;

    final start = dateOnly(fromDate!);
    final end = dateOnly(toDate!);
    final total = widget.accommodation.pricePerNight * nights;
    final textTheme = Theme.of(context).textTheme;

    final choice = await showDialog<_PayChoice>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('When do you want to pay?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.accommodation.name, style: textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              '${DateFormat('d MMM y').format(start)} - ${DateFormat('d MMM y').format(end)}',
              style: textTheme.bodySmall,
            ),
            Text(
              '$nights night${nights > 1 ? 's' : ''} · $numberOfGuests guest${numberOfGuests > 1 ? 's' : ''}',
              style: textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Text('\$${total.toStringAsFixed(2)}', style: textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Pay now opens PayPal straight away. Pay later holds the booking and leaves the payment for the Trips screen. Either way the host still has to answer, and the amount is worked out again on the server before you pay.',
              style: textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Back'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(_PayChoice.later),
            child: const Text('Pay later'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(_PayChoice.now),
            child: const Text('Pay now'),
          ),
        ],
      ),
    );

    if (choice == null || !mounted) return;

    final reservation = ReservationPOST(
      accommodationId: widget.accommodation.id,
      startDate: start,
      endDate: end,
      numberOfGuests: numberOfGuests,
    );

    if (choice == _PayChoice.now) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CheckoutScreen.forNewBooking(
            accommodationName: widget.accommodation.name,
            reservation: reservation,
          ),
        ),
      );
      return;
    }

    await _holdWithoutPaying(reservation);
  }

  Future<void> _holdWithoutPaying(ReservationPOST reservation) async {
    setState(() => _placing = true);

    try {
      await Provider.of<ReservationProvider>(
        context,
        listen: false,
      ).makeReservation(reservation);
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ReservationConfirmationPage.unpaid(
            accommodationName: widget.accommodation.name,
          ),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _placing = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final reservedDates = Provider.of<ReservationProvider>(
      context,
    ).reservedDates;
    final reservedRanges = reservedDates
        .map((map) => DateTimeRange(start: map['Start']!, end: map['End']!))
        .toList();

    final today = dateOnly(DateTime.now());
    final lastDay = today.add(const Duration(days: 365));
    var focusedDay = firstFreeDay.isBefore(today) ? today : firstFreeDay;
    while (isDayTaken(focusedDay, reservedRanges) &&
        focusedDay.isBefore(lastDay)) {
      focusedDay = focusedDay.add(const Duration(days: 1));
    }

    final nights = (fromDate != null && toDate != null)
        ? dateOnly(toDate!).difference(dateOnly(fromDate!)).inDays
        : 0;
    final canBook = nights > 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Choose dates')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Guests', style: textTheme.titleMedium),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(AppColors.radiusMd),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$numberOfGuests guest${numberOfGuests > 1 ? 's' : ''}',
                    style: textTheme.bodyMedium,
                  ),
                  Row(
                    children: [
                      _StepperCircle(
                        icon: PhosphorIcons.minus(),
                        enabled: numberOfGuests > 1,
                        onTap: () => setState(() {
                          if (numberOfGuests > 1) numberOfGuests--;
                        }),
                      ),
                      const SizedBox(width: 14),
                      _StepperCircle(
                        icon: PhosphorIcons.plus(),
                        enabled: true,
                        accent: true,
                        onTap: () => setState(() => numberOfGuests++),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Text('Dates', style: textTheme.titleMedium),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(AppColors.radiusMd),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: TableCalendar(
                firstDay: today,
                lastDay: lastDay,
                focusedDay: focusedDay,
                calendarFormat: _calendarFormat,
                startingDayOfWeek: StartingDayOfWeek.monday,
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 12,
                  ),
                  weekendStyle: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 12,
                  ),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: textTheme.bodyMedium ?? const TextStyle(),
                  leftChevronIcon: Icon(
                    PhosphorIcons.caretLeft(),
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  rightChevronIcon: Icon(
                    PhosphorIcons.caretRight(),
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                onDaySelected: (selectedDay, focused) {
                  final day = dateOnly(selectedDay);

                  if (isDayTaken(day, reservedRanges)) {
                    setState(() => firstFreeDay = focused);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('That day is already booked.'),
                      ),
                    );
                    return;
                  }

                  final startsOver =
                      fromDate == null ||
                      toDate != null ||
                      !day.isAfter(dateOnly(fromDate!));

                  if (startsOver) {
                    setState(() {
                      firstFreeDay = focused;
                      fromDate = day;
                      toDate = null;
                    });
                    return;
                  }

                  if (rangeOverlaps(fromDate!, day, reservedRanges)) {
                    setState(() {
                      firstFreeDay = focused;
                      fromDate = day;
                      toDate = null;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'That range runs across a booking that is already taken. Check-in moved to the day you picked.',
                        ),
                      ),
                    );
                    return;
                  }

                  setState(() {
                    firstFreeDay = focused;
                    toDate = day;
                  });
                },
                selectedDayPredicate: (day) {
                  if (fromDate == null) return false;
                  final d = dateOnly(day);
                  final from = dateOnly(fromDate!);
                  if (toDate == null) return d.isAtSameMomentAs(from);
                  return !d.isBefore(from) && !d.isAfter(dateOnly(toDate!));
                },
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, date, events) {
                    if (isDayTaken(date, reservedRanges)) {
                      return _takenDay(date);
                    }
                    return Center(
                      child: Text(
                        date.day.toString(),
                        style: const TextStyle(color: AppColors.text),
                      ),
                    );
                  },
                  outsideBuilder: (context, date, events) {
                    if (isDayTaken(date, reservedRanges)) {
                      return _takenDay(date, outside: true);
                    }
                    return Center(
                      child: Text(
                        date.day.toString(),
                        style: TextStyle(
                          color: AppColors.textTertiary.withValues(alpha: 0.6),
                        ),
                      ),
                    );
                  },
                  selectedBuilder: (context, date, events) {
                    return Center(
                      child: Container(
                        height: 36,
                        width: 36,
                        decoration: const BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            date.day.toString(),
                            style: const TextStyle(color: AppColors.bg),
                          ),
                        ),
                      ),
                    );
                  },
                  todayBuilder: (context, date, events) {
                    final taken = isDayTaken(date, reservedRanges);
                    return Center(
                      child: Container(
                        height: 36,
                        width: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: taken
                              ? AppColors.error.withValues(alpha: 0.14)
                              : null,
                          border: Border.all(
                            color: taken ? AppColors.error : AppColors.accent,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            date.day.toString(),
                            style: TextStyle(
                              color: taken ? AppColors.error : AppColors.text,
                              decoration: taken
                                  ? TextDecoration.lineThrough
                                  : null,
                              decorationColor: AppColors.error,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            if (fromDate != null) ...[
              const SizedBox(height: 10),
              Text(
                canBook
                    ? '$nights night${nights > 1 ? 's' : ''} selected'
                    : 'Pick a check-out date',
                style: textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 26),
            OutlinedButton(
              onPressed: canBook && !_placing
                  ? () => _openCheckout(nights)
                  : null,
              child: _placing
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Confirm booking'),
            ),
            if (_placing)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Holding your dates without paying...',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            else if (!canBook)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  fromDate == null
                      ? 'Pick a check-in day, then a check-out day.'
                      : 'Pick a check-out day. A stay runs at least one night, so it cannot end on the day it starts.',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StepperCircle extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final bool accent;
  final VoidCallback onTap;

  const _StepperCircle({
    required this.icon,
    required this.enabled,
    required this.onTap,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: enabled ? onTap : null,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: !enabled
                ? AppColors.border.withValues(alpha: 0.45)
                : accent
                ? AppColors.accent
                : AppColors.border,
          ),
        ),
        child: Icon(
          icon,
          size: 14,
          color: !enabled
              ? AppColors.textTertiary.withValues(alpha: 0.45)
              : accent
              ? AppColors.accentText
              : AppColors.textSecondary,
        ),
      ),
    );
  }
}
