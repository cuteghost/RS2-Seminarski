import 'package:ebooking/config/app_theme.dart';
import 'package:ebooking/models/reservation_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum EarningsRange {
  month('Month', 'This month'),
  quarter('Quarter', 'This quarter'),
  year('Year', 'This year');

  const EarningsRange(this.label, this.currentLabel);

  final String label;
  final String currentLabel;
}

class EarningsBucket {
  const EarningsBucket({required this.label, required this.total});

  final String label;
  final double total;
}

bool earningCounts(ReservationGET reservation) =>
    reservation.status == ReservationStatus.confirmed ||
    reservation.status == ReservationStatus.completed;

double earningOf(ReservationGET reservation) => reservation.totalPrice;

List<EarningsBucket> earningsBuckets(
  List<ReservationGET> reservations,
  EarningsRange range,
) {
  final counted = reservations.where(earningCounts).toList();
  final now = DateTime.now();

  double totalWhere(bool Function(DateTime checkIn) test) => counted
      .where((r) => test(r.startDate))
      .fold<double>(0, (sum, r) => sum + earningOf(r));

  switch (range) {
    case EarningsRange.month:
      return List<EarningsBucket>.generate(6, (index) {
        final month = DateTime(now.year, now.month - (5 - index));
        return EarningsBucket(
          label: DateFormat('MMM').format(month),
          total: totalWhere(
            (checkIn) =>
                checkIn.year == month.year && checkIn.month == month.month,
          ),
        );
      });
    case EarningsRange.quarter:
      final current = now.year * 4 + (now.month - 1) ~/ 3;
      return List<EarningsBucket>.generate(4, (index) {
        final absolute = current - (3 - index);
        final year = absolute ~/ 4;
        final quarter = absolute % 4;
        return EarningsBucket(
          label: 'Q${quarter + 1}',
          total: totalWhere(
            (checkIn) =>
                checkIn.year == year && (checkIn.month - 1) ~/ 3 == quarter,
          ),
        );
      });
    case EarningsRange.year:
      return List<EarningsBucket>.generate(3, (index) {
        final year = now.year - (2 - index);
        return EarningsBucket(
          label: '$year',
          total: totalWhere((checkIn) => checkIn.year == year),
        );
      });
  }
}

String formatEarnings(double value) {
  if (value >= 10000) return '\$${(value / 1000).toStringAsFixed(0)}k';
  if (value >= 1000) return '\$${(value / 1000).toStringAsFixed(1)}k';
  return '\$${value.toStringAsFixed(0)}';
}

class PartnerEarningsCard extends StatefulWidget {
  const PartnerEarningsCard({
    super.key,
    required this.reservations,
    this.errorMessage,
  });

  final List<ReservationGET> reservations;
  final String? errorMessage;

  @override
  State<PartnerEarningsCard> createState() => _PartnerEarningsCardState();
}

class _PartnerEarningsCardState extends State<PartnerEarningsCard> {
  EarningsRange _range = EarningsRange.month;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final buckets = earningsBuckets(widget.reservations, _range);
    final current = buckets.isEmpty ? 0.0 : buckets.last.total;
    final highest = buckets.fold<double>(
      0,
      (max, bucket) => bucket.total > max ? bucket.total : max,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppColors.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('EARNINGS', style: textTheme.labelSmall),
          const SizedBox(height: 5),
          Text(
            '\$${NumberFormat('#,##0').format(current)}',
            style: textTheme.titleLarge,
          ),
          Text(_range.currentLabel, style: textTheme.bodySmall),
          const SizedBox(height: 14),
          Row(
            children: [
              for (final range in EarningsRange.values)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _RangeChip(
                    label: range.label,
                    selected: range == _range,
                    onTap: () => setState(() => _range = range),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (widget.errorMessage != null)
            Text(widget.errorMessage!, style: textTheme.bodySmall)
          else if (highest == 0)
            Text(
              'No confirmed stays in this period yet.',
              style: textTheme.bodySmall,
            )
          else
            SizedBox(
              height: 132,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var index = 0; index < buckets.length; index++)
                    Expanded(
                      child: _Bar(
                        bucket: buckets[index],
                        highest: highest,
                        current: index == buckets.length - 1,
                      ),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 10),
          Text(
            'Confirmed and completed stays, counted on the check-in date.',
            style: textTheme.bodySmall?.copyWith(color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}

class _RangeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RangeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      borderRadius: BorderRadius.circular(AppColors.radiusSm),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.accentTint : Colors.transparent,
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(AppColors.radiusSm),
        ),
        child: Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: selected ? AppColors.accentText : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final EarningsBucket bucket;
  final double highest;
  final bool current;

  const _Bar({
    required this.bucket,
    required this.highest,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Column(
        children: [
          Text(
            bucket.total == 0 ? '' : formatEarnings(bucket.total),
            style: TextStyle(
              fontSize: 9.5,
              color: current ? AppColors.accentText : AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (bucket.total == 0) return const SizedBox.shrink();
                final height = (bucket.total / highest) * constraints.maxHeight;
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: height < 3 ? 3 : height,
                    decoration: BoxDecoration(
                      color: current ? AppColors.accent : AppColors.accentTint,
                      border: Border.all(
                        color: current ? AppColors.accent : AppColors.border,
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(3),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 6),
          Text(bucket.label, style: textTheme.labelSmall),
        ],
      ),
    );
  }
}
