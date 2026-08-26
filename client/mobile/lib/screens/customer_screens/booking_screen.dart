import 'package:ebooking/config/app_theme.dart';
import 'package:ebooking/models/accomodation_model.dart';
import 'package:ebooking/models/reservation_model.dart';
import 'package:ebooking/providers/reservation_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:ebooking/screens/customer_screens/checkout_screen.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

class BookingScreen extends StatefulWidget {
  final AccommodationGET accommodation;

  const BookingScreen({super.key, required this.accommodation});

  @override
  BookingScreenState createState() => BookingScreenState();
}

class BookingScreenState extends State<BookingScreen> {
  int numberOfGuests = 1;
  DateTime? fromDate;
  DateTime? toDate;
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime firstFreeDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    Provider.of<ReservationProvider>(context, listen: false)
        .fetchReservedDates(widget.accommodation.id);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    List<Map<String, DateTime>> reservedDates =
        Provider.of<ReservationProvider>(context).reservedDates;
    List<DateTimeRange> reservedRanges = reservedDates.map((map) {
      return DateTimeRange(start: map['Start']!, end: map['End']!);
    }).toList();
    while (reservedRanges.any((range) =>
        firstFreeDay.isAfter(range.start) &&
        firstFreeDay.isBefore(range.end))) {
      firstFreeDay = firstFreeDay.add(const Duration(days: 1));
    }

    final nights =
        (fromDate != null && toDate != null) ? toDate!.difference(fromDate!).inDays : 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose dates'),
      ),
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
                  Text('$numberOfGuests guest${numberOfGuests > 1 ? 's' : ''}',
                      style: textTheme.bodyMedium),
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
                firstDay: DateTime.now(),
                lastDay: DateTime.now().add(const Duration(days: 365)),
                focusedDay: firstFreeDay,
                calendarFormat: _calendarFormat,
                startingDayOfWeek: StartingDayOfWeek.monday,
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: TextStyle(color: AppColors.textTertiary, fontSize: 12),
                  weekendStyle: TextStyle(color: AppColors.textTertiary, fontSize: 12),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: textTheme.bodyMedium ?? const TextStyle(),
                  leftChevronIcon:
                      Icon(PhosphorIcons.caretLeft(), size: 16, color: AppColors.textSecondary),
                  rightChevronIcon:
                      Icon(PhosphorIcons.caretRight(), size: 16, color: AppColors.textSecondary),
                ),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    firstFreeDay = focusedDay;
                  });

                  if (reservedRanges.any((range) =>
                      selectedDay.isAfter(range.start) &&
                      selectedDay.isBefore(range.end))) {
                    setState(() {
                      fromDate = null;
                      toDate = null;
                    });
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Those dates overlap an existing booking.'),
                      ),
                    );
                    return;
                  } else if (fromDate == null || toDate != null) {
                    setState(() {
                      fromDate = selectedDay;
                      toDate = null;
                    });
                  } else if (selectedDay.isBefore(fromDate!)) {
                    setState(() {
                      fromDate = selectedDay;
                      toDate = null;
                    });
                  } else {
                    if (reservedRanges.any((range) =>
                        (range.start.isAfter(fromDate!) &&
                            range.start.isBefore(selectedDay)) ||
                        (range.end.isAfter(fromDate!) &&
                            range.end.isBefore(selectedDay)))) {
                      setState(() {
                        fromDate = null;
                        toDate = null;
                      });
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('That range crosses an existing booking.'),
                        ),
                      );
                      return;
                    } else {
                      setState(() {
                        toDate = selectedDay;
                      });
                    }
                  }
                },
                selectedDayPredicate: (day) {
                  if (reservedRanges.any((range) =>
                      (day.isAfter(range.start) && day.isBefore(range.end)) ||
                      isSameDay(range.end, day))) {
                    return false;
                  }
                  return (fromDate != null &&
                          toDate != null &&
                          ((day.isAfter(fromDate!) &&
                                  day.isBefore(
                                      toDate!.add(const Duration(days: 1)))) ||
                              isSameDay(day, fromDate!) ||
                              isSameDay(day, toDate!))) ||
                      (fromDate != null &&
                          toDate == null &&
                          isSameDay(day, fromDate!));
                },
                // Plain grid: only unavailable and selected days are marked,
                // instead of every day being a red/green traffic light.
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, date, events) {
                    final dateOnly = DateTime(date.year, date.month, date.day);
                    final isReserved = reservedRanges.any((range) =>
                        dateOnly.isAtSameMomentAs(DateTime(
                            range.start.year, range.start.month, range.start.day)) ||
                        dateOnly.isAtSameMomentAs(DateTime(
                            range.end.year, range.end.month, range.end.day)) ||
                        (dateOnly.isAfter(range.start) &&
                            dateOnly.isBefore(range.end)));

                    if (isReserved) {
                      return Center(
                        child: Text(
                          date.day.toString(),
                          style: TextStyle(
                            color: AppColors.textTertiary,
                            decoration: TextDecoration.lineThrough,
                            decorationColor: AppColors.error,
                          ),
                        ),
                      );
                    }
                    return Center(
                      child: Text(date.day.toString(),
                          style: const TextStyle(color: AppColors.text)),
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
                          child: Text(date.day.toString(),
                              style: const TextStyle(color: AppColors.bg)),
                        ),
                      ),
                    );
                  },
                  todayBuilder: (context, date, events) {
                    return Center(
                      child: Container(
                        height: 36,
                        width: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.accent),
                        ),
                        child: Center(
                          child: Text(date.day.toString(),
                              style: const TextStyle(color: AppColors.text)),
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
                toDate != null
                    ? '$nights night${nights > 1 ? 's' : ''} selected'
                    : 'Pick a check-out date',
                style: textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 26),
            OutlinedButton(
              onPressed: () {
                if (fromDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select a valid date range'),
                    ),
                  );
                  return;
                }
                toDate ??= fromDate;
                final reservation = ReservationPOST(
                  accommodationId: widget.accommodation.id,
                  startDate: fromDate!,
                  endDate: toDate!,
                  numberOfGuests: numberOfGuests,
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CheckoutScreen(
                          numberOfDays:
                              toDate!.difference(fromDate!).inDays + 1,
                          pricePerNight: widget.accommodation.pricePerNight,
                          accommodationId: widget.accommodation.id,
                          accommodationName: widget.accommodation.name,
                          reservation: reservation)),
                );
              },
              child: const Text('Confirm booking'),
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
